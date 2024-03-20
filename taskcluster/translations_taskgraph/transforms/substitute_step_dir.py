# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# This transform has a very simple job: cast fields in a task definition from
# one type to another. The only reason it exists is because we have some fields
# that `task_context` fills in as a string, but that other transforms or code
# requires to be an int.

from taskgraph.transforms.base import TransformSequence
from taskgraph.util.schema import Schema
from voluptuous import ALLOW_EXTRA, Optional

from translations_taskgraph.util.substitution import substitute

transforms = TransformSequence()

@transforms.add
def substitute_step_dir(config, jobs):
    for job in jobs:
        if len(job["dependencies"]) != 1:
            raise Exception("beetmover tasks must have exactly one dependency")

        substitute(job["worker"]["artifact-map"], step_dir=list(job["dependencies"].values())[0])
        yield job
