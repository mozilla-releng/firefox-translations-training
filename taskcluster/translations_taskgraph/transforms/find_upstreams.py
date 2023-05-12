import copy

from taskgraph.transforms.base import TransformSequence
from taskgraph.util.schema import Schema, optionally_keyed_by, resolve_keyed_by
from voluptuous import ALLOW_EXTRA, Required

SCHEMA = Schema(
    {
        Required("upstreams-config"): {
            Required("locale-pair"): {
                Required("src"): str,
                Required("trg"): str,
            },
            Required("upstream-task"): optionally_keyed_by("cleaning-type", str),
            Required("upstream-artifacts"): [str],
        },
    },
    extra=ALLOW_EXTRA,
)

by_locales = TransformSequence()
by_locales.add_validate(SCHEMA)

# TODO: this ought to live elsewhere
def get_cleaning_type(src, trg, upstreams):
    candidates = set()

    for upstream in upstreams:
        if upstream.kind not in ("bicleaner", "clean"):
            continue

        if upstream.attributes["src_locale"] != src or upstream.attributes["trg_locale"] != trg:
            continue

        candidates.add(upstream.attributes["cleaning-type"])

    for type_ in ("bicleaner-ai", "bicleaner", "clean"):
        if type_ in candidates:
            return type_

    raise Exception(f"Unable to find cleaning type for {src_locale}-{trg_locale}!")


@by_locales.add
def upstreams_for_locales(config, jobs):
    for job in jobs:
        upstreams_config = job.pop("upstreams-config")
        src = upstreams_config["locale-pair"]["src"]
        trg = upstreams_config["locale-pair"]["trg"]
        artifacts = upstreams_config["upstream-artifacts"]

        cleaning_type = get_cleaning_type(src, trg, config.kind_dependencies_tasks.values())

        resolve_keyed_by(
            upstreams_config,
            "upstream-task",
            item_name=job["description"],
            **{"cleaning-type": cleaning_type},
        )

        upstream_task = upstreams_config["upstream-task"]

        subjob = copy.deepcopy(job)
        subjob.setdefault("dependencies", {})
        subjob.setdefault("fetches", {})

        # Now that we've resolved which type of upstream task we want, we need to
        # find all instances of that task for our locale pair, add them to our
        # dependencies, and the necessary artifacts to our fetches.
        # TODO: this shouldn't pull in _all_ tasks, just ones that were specified in
        # the params
        for task in config.kind_dependencies_tasks.values():
            if not task.label.startswith(upstream_task):
                continue
            # TODO: get rid of this hack
            if upstream_task == "bicleaner" and task.label.startswith("bicleaner-ai"):
                continue

            subs = {
                "src_locale": src,
                "trg_locale": trg,
                "dataset_no_slashes": task.attributes["dataset"].replace("/", "."),
            }

            subjob["dependencies"][task.label] = task.label
            subjob["fetches"].setdefault(task.label, [])
            for artifact in artifacts:
                subjob["fetches"][task.label].append(
                    {
                        "artifact": artifact.format(**subs),
                        "extract": False,
                    }
                )
            
        yield subjob
