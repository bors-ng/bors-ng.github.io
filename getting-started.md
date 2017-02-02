---
title: Getting started
layout: page
---

# Setting up bors

Bors-NG does not replace CI tools like Travis CI;
it's just a frontend that implements a particular workflow on top of it.
So the first step of setting up bors is setting something up to automatically run your tests.
It should be able to run the contents of a particular branch
and report its results using a GitHub Status notification
(the little <span style="color:orange" title="The build is in progress">&bull;</span>, <span style="color:green" title="Build succeeded">&#10003;</span>, or <span style="color:red" title="Build failed">&times;</span> next to a commit in the commits list).
Jenkins requires the GitHub plugin to do this.

Your CI system should build the "staging" and "trying" branches, but should not build a branch called "staging.tmp".
If your CI system is misconfigured in this sense, bors should notify you.

For example, add this to your .travis.yml or appveyor.yml file:

```yaml
branches:
  only:
    # This is where pull requests from "bors r+" are built.
    - staging
    # This is where pull requests from "bors try" are built.
    - trying
    # Uncomment this to enable building pull requests.
    #- master
```

Once you have something like Travis, AppVeyor, CircleCI, Jenkins, TaskCluster, BuildBot,
or anything else that can work in their stead,
connect bors-ng to your repo <a href="https://github.com/integration/bors-ng">from within GitHub</a>.

The final step is to create a `bors.toml` file in your repo.
This will specify what CI systems Bors-NG should use,
along with other metadata like timeouts.
The `status` key specifies which GitHub Statuses it uses to determine a successful or failed build.
For example, this will work for a repo with Travis CI and AppVeyor:

```toml
status = [
  "continuous-integration/travis-ci/push",
  "continuous-integration/appveyor/branch"
]
# Uncomment this to use a two hour timeout.
# The default is one hour.
#timeout = 7200
```

Once that's there, `bors r+` will work.
Note that bors reads bors.toml from the pull requests it's merging,
not the one in master,
so changes to the file get checked before they land.

# Reviewing pull requests

Once you've set it up, instead of clicking the green "Merge Button",
leave a comment like this on the pull request:

> bors r+

The pull request,
as well as any other pull requests that are reviewed around the same time,
will be merged into a branch called "staging".
Your CI tool will test it in there,
and report the result back where Bors-NG can see it.
If that result is "OK", master gets fast-forwarded to reach it.

The status can be seen in <a href="https://bors-ng.herokuapp.com/">the Dashboard page</a>,
which also makes a good one-stop-shop to see pull requests that are waiting for review.
The dashboard page is also where the permission to review a pull request can be handed out to other people (this list is too sensitive for bors.toml, and it can't affect the success of a build).

There's also:

> bors try

When this is run, your branch and master get merged into "trying",
and bors will report the results just like the "staging" would
(you probably want to make sure your CI system handles staging and trying the same).
Only reviewers can push to this, since the backend CI system may not be well-isolated.
