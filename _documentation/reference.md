---
title: Reference manual
layout: page
redirect_from: /reference/
---

## Commands (pull request comments)

| Syntax | Description |
|--------|-------------|
| bors r+ | Run the test suite, and push to master if it passes. Short for "reviewed: looks good."
| bors r=<list> | Same as r+, but the "reviewer" in the commit log will be recorded as the user(s) given as the argument.
| bors r- | Cancel an r+ or r=.
| bors try | Run the test suite, without pushing to master.
| bors delegate+ | Allow the pull request author to r+ their changes.
| bors delegate=<list> | Allow the listed users to r+ this pull request's changes.
| bors ping | Will respond if bors is set up.

Note that the keyword (`bors`) may be separated with a space or a colon. That is, `bors try` and `bors: try` are the same thing.

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
