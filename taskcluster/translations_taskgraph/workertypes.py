from taskgraph.transforms.task import payload_builder


@payload_builder(
    "beetmover-translations",
    schema={
        # todo: bool this after keyed by is fixed
        "dryrun": dict,
        "upstream-artifacts": dict,
        "artifact-map": dict,
    },
)
def build_beetmover_payload(config, task, task_def):
    worker = task["worker"]
    task_def["tags"]["worker-implementation"] = "scriptworker"
    task_def["payload"] = {
        "dryrun": worker["dryrun"],
        "upstream-artifacts": worker["upstream-artifacts"],
        "artifactMap": worker["artifact-map"],
    }
