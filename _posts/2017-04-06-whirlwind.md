---
layout:     post
title:      The context of bors-ng
date:       2017-04-26 09:39:00
summary:    A whirlwind tour of a build workflow
categories: guide
---

Bors implements a workflow that enforces the rule that *the master branch always passes all the tests*.
Bors-NG is not the only bot that implements this, or even the first.

The original bors (Bors-OG)
===========================

[Bors-OG is in this repository][graydon/bors].

Once it's set up on a repository, you can use it the same way as Bors-NG,
but I don't recommend it and neither does its creator.
Bors-OG needs to be configured with a user account on GitHub,
then you run it in a cron job.

[graydon/bors]: https://github.com/graydon/bors

The Rust project eventually abandoned it because they couldn't keep the latency they wanted
and avoid hitting GitHub rate limits.
So another developer redid it.


Homu; Bors as a webhook
=======================

[The original Homu is here][barosl/homu].
[The actively maintained fork, by the Servo project, is here][servo/homu].

Homu also works pretty much the same as Bors.
It's what Rust and Servo are using.
It's a webhook, which means it has far lower latency than Bors-OG,
and it doesn't hit GitHub's rate limit as quickly as the polling approach.
It helps that homu maintains a database, so it doesn't have to fetch as much information to do anything.

The Rust community organization have a fork of Servo's Homu, which they renamed bors\*.
It's Homu, and Rust isn't actually using it (they're using Servo's fork).

\* **Update 12 September 2017:** This repository was deleted because it was unused.

[barosl/homu]: https://github.com/barosl/homu
[servo/homu]: https://github.com/servo/homu


So where does Bors-NG fit into all of this?
===========================================

Bors-NG was created after Homu, to solve two major problems it had:

  * *Homu is difficult to set up.*
    The base distribution doesn't have any way to administer one's repository without admin access to the whole homu.cfg file.
    The Rust Community Team wanted to be able to offer "Bors as a Service."
  * *Homu doesn't scale very well.*
    Homu tests pull requests one at a time.
    The Rust project, nowadays, regularly has a queue of pull requests that's more than a day long.

Bors-NG solves both of these problems.
It can be (and is) offered as a service,
and, by batching, it can reduce Homu's O(n) builds to a more managable O(E*log(N)) number of builds.


Some other design trade-offs that Bors-NG makes
-----------------------------------------------

### Batching

Batching is not the only way to achieve optimistic concurrency.
It can also be done with parallel building, like [OpenStack's Zuul does](https://docs.openstack.org/infra/zuul/).
It doesn't use parallel building, mostly because it requires a huge number of build machines,
especially for a project like Rust where the builders aren't all homogenous.

### The Elixir programming language

The most contentious choice, even though it might be the least important.

Elixir was chosen for its fault isolation features. Since, unlike Bors-OG, Homu, and Zuul,
Bors-NG is intended to be a publically used service with a large number of independent projects running on it,
one misconfigured project should not be able to bring down the entire system.

Every project gets its own set of independent BEAM processes,
and the supervisors for each project's processes will not attempt to respawn them if they die.
So if a project manages to trash its internal state, it will not affect anyone else.

A lot of projects achieve something similar using containers or even separate VMs.
Doing it with OTP is cheaper, and it ends up using less memory.

### The name

The second most contentious choice.
It's named Bors-NG because I have less naming and marketing skill than someone who is terrible at naming things.
