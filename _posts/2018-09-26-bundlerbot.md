---
layout:     post
title:      How bundler combines bors-ng with their own welcome bot 
date:       2018-09-26 00:00:00
summary:    Running more than one GitHub app with the same name
categories: writeup
---

The central principle of bors-ng is to be an easy-to-set-up implementation of an uncomplicated continuous testing regime, and to do that one thing well. It doesn't take care of deployment, it doesn't sort your issues, it doesn't update your dependencies, and it doesn't post a comment on all first-time contributors' pull requests.

If you want all that stuff, you can add more apps to do it. And if really want to make it look pro, you can do what [bundler](https://github.com/bundler/bundler) did.

This is their [greeter script](https://github.com/bundler/bundlerbot), called `bundlerbot`:

<p class="gallery"><img alt="screenshot of github" src="https://screenshotscdn.firefoxusercontent.com/images/8eeda687-77fb-449c-82bb-b6e95b20c1ca.png"></p>

This is their self-hosted instance of bors-ng, *also* called `bundlerbot`:

<p class="gallery"><img alt="screenshot of github" src="https://screenshotscdn.firefoxusercontent.com/images/f2c9b8c3-9e0a-419a-9079-c1cb1251481a.png"></p>

Making that work required three changes to the usual bors-ng setup.

* The authentication details --- the app ID, private key, and webhook secret --- were kept the same between the GitHub App configuration, the greeter bot, and their self-hosted bors-ng.
* The command trigger was changed from `bors` to `@bundlerbot`, after one of their maintainers [added an option to change it](https://github.com/bors-ng/bors-ng/pull/461/files).
* Instead of setting the webhook URL to point at bors-ng directly, they routed their webhooks to a service called [Zapier](https://zapier.com/) and configured it to re-send all of the webhooks twice: once to bundlerbot-bors, and once to their greeter.

<p class="gallery"><img alt="screenshot of Zapier" src="https://forum.bors.tech/uploads/default/optimized/1X/ae49fcea98dba465ef10041c6deab8a47500c369_1_455x500.png"></p>

Unfortunately, even though Zapier is nice and flexible, it required them to set all of the headers that needed to be re-sent one at a time: the request body for the forward should be sourced from the request body of the initial request, `X-GitHub-Delivery` should be pulled from `X-GitHub-Delivery` in the original request, `X-Hub-Signature` should be pulled from `X-Hub-Signature` in the original request, and so on. It's not hard to do, just annoying.

They also [set the committer email](https://forum.bors.tech/t/customizing-the-name-email-and-avatar-of-the-bots-merge-commits/166) to the same one that the now-unmaintained bundlerbot-homu used. This all allows them to maintain continuity as they evolve the underlying tech behind their GitHub automation, so no matter what third-party app or custom integration they use, it will always be just another iteration of `bundlerbot`.

--------

[Discussion thread on the bors forum](https://forum.bors.tech/t/how-bundler-combines-bors-ng-with-their-own-welcome-bot/226)
