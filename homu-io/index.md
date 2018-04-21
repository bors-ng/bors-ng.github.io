---
title: About homu
---

## What does homu do?

Homu is an implementation of the "not rocket science rule of engineering":
that a [branch of code] should be maintained that passes [all of the tests] all of the time.

It works by reordering the common way that [continuous integration] is done.
Normally, it goes in this order:

* A developer's "working branch" is uploaded to the shared repository.
* A [reviewer] checks that it's good, and, when satisfied that it is, merges it into the "master branch" and uploads the new master.
* A server cluster, running all of the OS's that the software product needs to run on, downloads the master branch and tests it.
* If the cluster says it passed, then it's probably suitable 
* If the cluster says it failed, the developers are expected to fix it. Now.

The problem is that the software product only gets tested after it's already been uploaded to the master branch,
and since other developers are expected to use the master branch as the basis for their own work,
they've started basing their work on a bad branch.

Homu does it this way:

* A developer's "working branch" is still uploaded the same way.
* A reviewer checks that it's good, and, when satisfied that it is, *sends a message to homu*.
* Homu merges it together with the master branch, but uploads it to a separate branch (typically called "auto").
* A server cluster, running all of the OS's, downloads the auto branch and tests it.
* If the cluster says it passed, homu responds by copying "auto" into "master" (verbatim, since auto is always master-plus-a-change).
* If the cluster says it failed, homu reports the error but does nothing else.

This helps when there are lots of developers, because the master branch is always a copy of auto that passed.
If reviewers approve changes more quickly than homu can build them, it will work through them one at a time in the order it receives them.

[branch of code]: https://en.wikipedia.org/wiki/Branching_(version_control)
[all of the tests]: https://en.wikipedia.org/wiki/Unit_testing
[continuous integration]: https://en.wikipedia.org/wiki/Continuous_integration
[reviewer]: https://en.wikipedia.org/wiki/Code_review

## What's going on with it?

**homu.io** was a free online service run by [@barosl] for the OSS community.
It was based on the open source [homu] app,
but it used a closed-source "frontend" for registering new repositories from the web.

It doesn't exist any more. [@barosl] hasn't been active on GitHub for years,
the homu.io domain was allowed to expire,
and nobody else has the source code for the frontend.
You can still run the OSS version of homu if you want,
like [Servo], [Rust], and [Bundler] are doing.

The [Servo fork] is considered the "canonical" version that you should use,
since they've been adding new features and fixing bugs in homu.
If you want to run your own instance,
[bundler has a guide] for running it on Heroku,
while Servo's guide will work for running it on a VPS.

[servo]: https://github.com/bors-servo
[rust]: https://github.com/bors
[bundler]: https://github.com/bundlerbot
[bundler has a guide]: https://github.com/bundler/bundlerbot-homu
[servo fork]: https://github.com/servo/homu
[@barosl]: https://github.com/barosl
[homu]: https://github.com/barosl/homu

## So what's bors?

[Bors-NG] is a complete open source,
modernized replacement for homu.io.
It has no "closed source" version;
what runs on [app.bors.tech] is what you get on GitHub.

[bors-ng]: https://github.com/bors-ng/bors-ng/
[app.bors.tech]: https://app.bors.tech/

It aims to be faster and more user-friendly while sticking to mostly the same idea.
You can register for the publicly-hosted version run by [@notriddle].
If you want to set up your own instance, but are having trouble with [the instructions],
please ask about it on [the forum],
where the rules are "it's better to just not answer the question than to be rude,
even if it's a question that's been asked before."

[the instructions]: https://github.com/bors-ng/bors-ng/blob/master/README.md#how-to-set-up-your-own-real-instance
[the forum]: https://forum.bors.tech/
[@notriddle]: https://github.com/notriddle/
