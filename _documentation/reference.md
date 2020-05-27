---
title: Reference
layout: page
redirect_from:
 - /reference/
 - /documentation/reference/
 - /documentation/dev/
permalink: /documentation/
description: All of the commands and configuration options supported by bors-ng
---

## Commands (pull request comments)

| Syntax | Description |
|--------|-------------|
| bors r+ | Run the test suite and push to the base branch if it passes. Short for "reviewed: looks good."
| bors merge | Equivalent to `bors r+`.
| bors r=[list] | Same as r+, but the "reviewer" in the commit log will be recorded as the user(s) given as the argument.
| bors merge=[list] | Equivalent to `bors r=[list]`
| bors r- | Cancel an r+, r=, merge, or merge=
| bors merge- | Equivalent to `bors r-`
| bors try | Run the test suite without pushing to master.
| bors try- | Cancel a try
| bors delegate+ <br> bors d+ | Allow the pull request author to r+ their changes.
| bors delegate=[list] <br> bors d=[list] | Allow the listed users to r+ this pull request's changes.
| bors ping | Check if bors is up. If it is, it will comment with _pong_.
| bors retry | Run the previous command a second time.
| bors p=[priority] | Set the priority of the current pull request. Pull requests with different priority are never batched together. The pull request with the bigger priority number goes first.
| bors r+ p=[priority] | Set the priority, run the test suite, and push to master (shorthand for doing p= and r+ one after the other).
| bors merge p=[priority] | Equivalent to `bors r+ p=[priority]`
| bors single on | Disable batching on this pull request
| bors single off | Enable batching

The keyword (`bors`) may be separated with a space or a colon. That is, `bors try` and `bors: try` are the same thing.
Also, the command will be recognized if, and only if, the word "bors" is at the beginning of a line.

This will be recognized as a command:

    > Like the other person said:
    bors r+

This will not be recognized as a command:

    > Like the other person said:
    > bors r+

And if you want to copy the above table into a markdown comment, make sure that you include the (optional) pipes at the beginning of every line, because [this will be recognized as a bunch of commands](https://github.com/behnam/rust-unic/pull/172#issuecomment-334326508), one after the other:

    Syntax | Description
    -------|------------
    bors r+ | Run the test suite and push to master if it passes. Short for "reviewed: looks good."
    bors merge | Equivalent to `bors r+`.
    bors r=[list] | Same as r+, but the "reviewer" in the commit log will be recorded as the user(s) given as the argument.
    bors merge=[list] | Equivalent to `bors r=[list]`
    bors r- | Cancel an r+, r=, merge, or merge=
    bors merge- | Equivalent to `bors r-`
    bors try | Run the test suite without pushing to master.
    bors try- | Cancel a try
    bors delegate+ <br> bors d+ | Allow the pull request author to r+ their changes.
    bors delegate=[list] <br> bors d=[list] | Allow the listed users to r+ this pull request's changes.
    bors ping | Check if bors is up. If it is, it will comment with _pong_.
    bors retry | Run the previous command a second time.
    bors p=[priority] | Set the priority of the current pull request. Pull requests with different priority are never batched together. The pull request with the bigger priority number goes first.
    bors r+ p=[priority] | Set the priority, run the test suite, and push to master (shorthand for doing p= and r+ one after the other).
    bors merge p=[priority] | Equivalent to `bors r+ p=[priority]`

On the other hand, bors will ignore this table if it's given [like this (with the optional pipes at the beginning of every line)](https://github.com/notriddle/test_repo/pull/118#issuecomment-334333878):



    | Syntax | Description
    |--------|------------
    | bors r+ | Run the test suite and push to master if it passes. Short for "reviewed: looks good."
    | bors merge | Equivalent to `bors r+`.
    | bors r=[list] | Same as r+, but the "reviewer" in the commit log will be recorded as the user(s) given as the argument.
    | bors merge=[list] | Equivalent to `bors r=[list]`
    | bors r- | Cancel an r+, r=, merge, or merge=
    | bors merge- | Equivalent to `bors r-`
    | bors try | Run the test suite without pushing to master.
    | bors try- | Cancel a try
    | bors delegate+ <br> bors d+ | Allow the pull request author to r+ their changes.
    | bors delegate=[list] <br> bors d=[list] | Allow the listed users to r+ this pull request's changes.
    | bors ping | Check if bors is up. If it is, it will comment with _pong_.
    | bors retry | Run the previous command a second time.
    | bors p=[priority] | Set the priority of the current pull request. Pull requests with different priority are never batched together. The pull request with the bigger priority number goes first.
    | bors r+ p=[priority] | Set the priority, run the test suite, and push to master (shorthand for doing p= and r+ one after the other).
    | bors merge p=[priority] | Equivalent to `bors r+ p=[priority]`

## Configuration (bors.toml)

| Name                   | Type        | Description |
|------------------------|-------------|-------------|
| status                 | \[pattern\] | List of commit statuses that must pass on the merge commit before it is pushed to master.
| block_labels           | \[string\]  | List of PR labels that may not be attached to a PR when it is r+-ed.
| pr_status              | \[string\]  | List of commit statuses that must pass on the PR commit when it is r+-ed.
| timeout_sec            | integer     | Number of seconds from when a merge commit is created to when its statuses must pass.
| required_approvals     | integer     | Number of project members who must approve the PR (using GitHub Reviews) before it is pushed to master.
| cut_body_after         | string      | A marker in the PR description that indicates boilerplate that does not belong in the commit message.
| delete_merged_branches | boolean     | If set to true, and if the PR branch is on the same repository that bors-ng itself is on, the branch will be deleted.
| committer.name         | string      | Set both committer details to have merge commits show up as authored by a specific user. |
| committer.email        | string      | |
| use_codeowners         | boolean     | If turned on, `CODEOWNERS` file will be parsed. [See GitHub's docs](https://help.github.com/en/articles/about-code-owners) for more info. |
| use_squash_merge       | boolean     | If turned on, commits will be Squashed before merging and the Pull Request will be Closed with `[Merged by Bors] - ` addition to the tile. [See Github's docs](https://help.github.com/en/articles/about-pull-request-merges#squash-and-merge-your-pull-request-commits) for more info. |

Note that underscores (`_`) and hyphens (`-`) are interchangable in configuration option names. That is, `pr_status` and `pr-status` are the same thing.

Patterns are written using SQL `LIKE` syntax. For example, this `status` directive will match any CI job that starts with `ci/gitlab/`:

```toml
status = [ 'ci/gitlab/%' ]
```

The committer options, if provided, should be given as a table:

```toml
[committer]
name = "King Ban"
email = "ban@example.com"
```

# Development resources

* <https://bors.tech/rfcs/>: RFCs, which are used to get feedback on new features and such
* <https://hexdocs.pm/elixir/syntax-reference.html>: Elixir language documentation
* <https://hexdocs.pm/phoenix/overview.html>: Phoenix web framework documentation
* <https://developer.github.com/apps/>: GitHub API documentation
* <https://bors.tech/devdocs/bors-ng/hacking.html>: Bors-NG source-level documentation
