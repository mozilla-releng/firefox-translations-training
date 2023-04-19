import copy

from taskgraph.transforms.base import TransformSequence

transforms = TransformSequence()


@transforms.add
def split_by_provider(config, jobs):
    for job in jobs:
        for provider in config.graph_config["datasets"].keys():
            subjob = copy.deepcopy(job)
            subjob["provider"] = provider
            subjob["name"] = subjob["name"].replace("{provider}", provider)
            yield subjob
