---
title: Getting started
description: How to set up bors-ng on your GitHub repo
layout: page
redirect_from: /getting-started/
---

# Setting up bors

Bors-NG does not replace CI tools like Travis CI;
it's just a frontend that implements a particular workflow on top of it.
So the first step of setting up bors is setting something up to automatically run your tests.
It should be able to run the contents of a particular branch
and report its results using a GitHub Status notification
(the little <abbr style="color:orange" title="The build is in progress">&bull;</abbr>, <abbr style="color:green" title="Build succeeded">&#10003;</abbr>, or <abbr style="color:red" title="Build failed">&times;</abbr> next to a commit in the commits list). Newer CI systems, like Travis and AppVeyor, will do this by default. Jenkins and BuildBot have plugins for it.

Your CI system should build the "staging" and "trying" branches, but should not build the "staging.tmp" and "trying.tmp" branches.
If your CI system is misconfigured to do this, bors should notify you. For example, add this to your .travis.yml or appveyor.yml file:

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

Once you have a Continuous Integration service running,
connect bors-ng to your repo <a href="https://github.com/apps/bors">from within GitHub</a>.

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
#timeout_sec = 7200
```

Once that's there, `bors r+` will work.
Note that bors reads bors.toml from the pull requests it's merging,
not the one in master,
so changes to the file get checked before they land.

# Reviewing pull requests

Once you've set it up, instead of clicking the green "Merge Button",
leave a comment like this on the pull request:

> bors r+

Equivalently, you can comment the following:

> bors merge

The pull request,
as well as any other pull requests that are reviewed around the same time,
will be merged into a branch called "staging".
Your CI tool will test it in there,
and report the result back where Bors-NG can see it.
If that result is "OK", master gets fast-forwarded to reach it.

The status can be seen in [the Dashboard page],
which also makes a good one-stop-shop to see pull requests that are waiting for review.

There's also:

> bors try

When this is run, your branch and master get merged into "trying",
and bors will report the results just like the "staging" would
(you probably want to make sure your CI system handles staging and trying the same).
Only reviewers can push to this, since the backend CI system may not be well-isolated.

# Adding reviewers

If you click your nickname on [the Dashboard page],
there's a button to get a list of Repositories.
Click there, then click the repository you want to look at.

There's two tabs: a Pull requests tab and a Settings tab.
Click the settings tab.

In there is a list of currently set up reviewers.
Type the GitHub login name of the user you want to add,
into the text field next to the "Add" button, then click it.

[the Dashboard page]: https://app.bors.tech/

## Delegating reviews

In addition to adding reviewers who can approve any PR in the repo,
you can "delegate" permission to approve a single PR to anyone else.
It works like this:

> * @some-user: bors r+
> * @bors[bot]: Permission denied
> * @some-reviewer: bors delegate=some-user
> * @bors[bot]: some-user now has permission to review this pull request.
> * @some-user: bors r+
> * @bors[bot]: Added to queue

If some-user happens to be the pull request author, you can also use the shorthand `delegate+` command.

# More info

You can find more info in the [reference manual].

[reference manual]: //bors.tech/documentation/reference/

# If it doesn't work

It might be one of these common problems:

  * bors needs to be able to force-push to the "staging", "staging.tmp", "trying", and "trying.tmp" branches.
    It doesn't need to be able to force-push to "master",
    but it needs to be able to regular-push a commit there.

    You can check this on GitHub in your repository's Settings tab, in the Branches section.
    The "master" branch can be protected,
    and since bors will usually be the only thing that commits directly to master,
    you can set it to require the "bors" Commit Status to push to master.
    Do not set the staging/trying branches to protected.

    If this is the problem, bors will not be able to get past the "waiting in the queue" stage,
    or it will falsely report a merge conflict.

  * When bors pushes a commit to the "staging" and "trying" branches,
    your CI system needs to run the test suite on that commit.
    You can test this by pushing a commit to one of those branches by hand and seeing if it runs.

    Your CI system will probably work with GitHub either by registering a webhook (Settings -> Webhooks), an integration, or a service (Settings -> Integrations & Services).
    If there's nothing about your CI system in either of those two screens, it probably isn't set up right.

    If this is the problem, bors will time out every time.

  * Your CI system needs to report success and failure as GitHub Commit Statuses.
    bors might support other ways to report success and failure someday,
    but commit statuses work for so many CI systems that it doesn't seem necessary right now.

    If you go to your repository's home page, change from "master" to the "staging" branch,
    then click the "**9,001** Commits" button, you'll see a list of commits.
    The one at the top of the list should have one of the checkmark/crossmark/dot icons next to it,
    with a tooltip like "2/2 checks OK" or "Failure: The Travis CI build failed" or "Success: The Travis CI build passed".
    If you click on it, it should link to your CI system.

    If this is the problem, bors will time out every time.

  * The bors integration needs to be enabled on your GitHub repo.
    If this is the problem, bors will not respond to commands.

  * When using protected branches, leave the `Require pull request reviews before merging` option unmarked, otherwise you'll start to get a lot of `422` errors. If you want to enforce reviews on your Pull Requests and/or you're using `CODEOWNERS`, require these options solely on bors with the respective options: `required_approvals` and `use_codeowners`. Also, make sure `bors` is included in the list allowed to push to the protected branch.

You can also get help on [our forum](https://forum.bors.tech). We won't chew you out if it turns out to be one of those problems after all.
