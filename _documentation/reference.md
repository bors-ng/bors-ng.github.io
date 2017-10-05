---
title: Reference manual
layout: page
redirect_from: /reference/
---

## Commands (pull request comments)

| Syntax | Description |
|--------|-------------|
| bors r+ | Run the test suite, and push to master if it passes. Short for "reviewed: looks good."
| bors r=[list] | Same as r+, but the "reviewer" in the commit log will be recorded as the user(s) given as the argument.
| bors r- | Cancel an r+ or r=.
| bors try | Run the test suite, without pushing to master.
| bors delegate+ | Allow the pull request author to r+ their changes.
| bors delegate=[list] | Allow the listed users to r+ this pull request's changes.
| bors ping | Will respond if bors is set up.

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
    bors r+ | Run the test suite
    bors r=[list] | Same as r+, but the "reviewer" will come from the argument
    bors r- | Cancel an r+ or r=
    bors try | Run the test suite without pushing
    bors delegate+ | Allow the pull request author to r+
    bors delegate=[list] | Allow the listed users to r+
    bors ping | Will respond if bors is set up

On the other hand, bors will ignore this table if it's given [like this (with the optional pipes at the beginning of every line)](https://github.com/notriddle/test_repo/pull/118#issuecomment-334333878):

    | Syntax | Description
    |--------|------------
    | bors r+ | Run the test suite
    | bors r=[list] | Same as r+, but the "reviewer" will come from the argument
    | bors r- | Cancel an r+ or r=
    | bors try | Run the test suite without pushing
    | bors delegate+ | Allow the pull request author to r+
    | bors delegate=[list] | Allow the listed users to r+
    | bors ping | Will respond if bors is set up

## Configuration (bors.toml)

| Name         | Type     | Description |
|--------------|----------|-------------|
| status       | [string] | List of commit statuses that must pass on the merge commit before it is pushed to master.
| block_labels | [string] | List of PR labels that may not be attached to a PR when it is r+-ed.
| pr_status    | [string] | List of commit statuses that must pass on the PR commit when it is r+-ed.
| timeout_sec  | integer  | Number of seconds from when a merge commit is created to when its statuses must pass.
| cut_body_after | string | A marker in the PR description that indicates boilerplate that does not belong in the commit message.
| delete_merged_branches | boolean | If set to true, and if the PR branch is on the same repository that bors-ng itself is on, the branch will be deleted.

Note that underscores (`_`) and hyphens (`-`) are interchangable in configuration option names. That is, `pr_status` and `pr-status` are the same thing.
