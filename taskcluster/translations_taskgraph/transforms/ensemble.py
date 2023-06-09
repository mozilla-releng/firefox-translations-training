import copy

from taskgraph.transforms.base import TransformSequence
from taskgraph.util.schema import Schema
from voluptuous import ALLOW_EXTRA, Optional, Required

from translations_taskgraph.util.dict_helpers import deep_get
from translations_taskgraph.util.substitution import substitute

SCHEMA = Schema(
    {
        Optional("ensemble-config"): {
            Required("number"): {
                "from-parameters": str,
            },
            Required("fan-out"): bool,
            Optional("fields"): [str],
        }
    },
    extra=ALLOW_EXTRA,
)

transforms = TransformSequence()
transforms.add_validate(SCHEMA)


@transforms.add
def transforms(config, jobs):
    for job in jobs:
        ensemble_config = job.pop("ensemble-config", None)
        if ensemble_config:
            number = deep_get(config.params, ensemble_config["number"]["from-parameters"])
            if ensemble_config["fan-out"] == True:
                for i in range(number):
                    ensemble_job = copy.deepcopy(job)
                    for field in ensemble_config.get("fields"):
                        container, subfield = ensemble_job, field
                        while "." in subfield:
                            f, subfield = subfield.split(".", 1)
                            container = container[f]

                        container[subfield] += f"-{i}"

                    yield ensemble_job
            else:
                for field in ensemble_config.get("fields"):
                    container, subfield = job, field
                    while "." in subfield:
                        f, subfield = subfield.split(".", 1)
                        container = container[f]

                    for i in range(number):
                        key = subfield.format(ensemble=i)
                        subcontainer = copy.deepcopy(container[subfield])
                        container[key] = substitute(subcontainer, ensemble=i)
                        if isinstance(container[key], str):
                            container[key] += f"-{i}"


                    container.pop(subfield)

                yield job
        else:
            yield job
