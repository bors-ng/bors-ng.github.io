---
layout:     post
title:      Responding to the Heroku service compromise
date:       2022-05-05 15:32:06
summary:    Rotating credentials howto
categories: incident-response
---

A few hours ago, Heroku sent out an email and an incident response notification that they had a database leaked. The public
instance, at [app.bors.tech], is run on Heroku.

Originally, they reported that their own GitHub integration had been hacked, which has no direct effect on Bors-NG.

However, now that we know [the hashed passwords were also stolen], prudence requires us to assume that the threat
actor may also have gotten the configuration environment variables, which store the integration PEM and other secrets
that could be used to gain write access to GitHub repositories.

[app.bors.tech]: https://app.bors.tech
[the hashed passwords were also stolen]: https://status.heroku.com/incidents/2413?updated

This guide will describe what I did, so that others who run their own heroku-based bors instances can do the same.

# Getting to the settings area for bors-ng

To create new authentication credentials, first, go into the developer page for your GitHub app. To find the bors-ng
organization's, for example, I went to the bors-ng organization page, clicked "Settings" in the tab bar, then clicked
"Developer settings" in the sidebar, then "GitHub Apps."

After getting to the list of all GitHub Apps on this organization, the next step is to click "Edit" on the `bors` app.

# Rotating the client secret

The Client Secret is used for authenticating yourself with the dashboard. You'll want to create a second one,
and save the short, random string it gives you, because once you look at it here, you'll never be allowed to look
at it again through that website.

Save the client secret as the `GITHUB_CLIENT_SECRET` Config Var. Config Vars are edited in the Heroku Dashboard
under the Settings tab for your app.

# Rotating the Private Key

The Private Key is the primary way bors-ng accesses the GitHub API. You'll want to generate a second one,
and download the file. To use it in bors-ng on heroku, you'll also need to base64 encode it, with a command like this:

    base64 -w0 < bors.2022-05-05.private-key.pem

Save the Private Key as the `GITHUB_INTEGRATION_PEM` Config Var.

# Rotating the webhook secret

The webhook secret is the last permanently-stored GitHub credential we'll need to worry about. GitHub expects us to
generate it ourselves, so if you have access to a UNIX-like command line and openssl, you'll generate it like
this from the command line:

    dd if=/dev/urandom of=/dev/stdout bs=256 count=1 | base64 -w1024

Save the webhook secret as the `GITHUB_WEBHOOK_SECRET` Config Var.

# Rotating the `SECRET_KEY_BASE`

Unlike all of the other credentials in here, this is not used by GitHub. The bors dashboard uses it to encrypt
its own cookies.

You can generate one that will work like this:

    dd if=/dev/urandom of=/dev/stdout bs=64 count=1 | base64 -w1024

Save it in the `SECRET_KEY_BASE` Config Var.

# Revoke all user tokens

This is just a button you click. It will log everyone out of the bors-ng dashboard.

# Forcing a redeploy

To make sure it's running the latest version, here's the commands I ran:

    # This gives me direct access to heroku's git repo
    heroku git:clone --app bors-2sgeew5xkczjb1nqkkx6
    cd bors-2sgeew5xkczjb1nqkkx6/
    # This allows me to pull the current version
    git remote add origin https://github.com/bors-ng/bors-ng
    git fetch origin
    # This makes it the current deployed version
    git reset --hard origin/master
    # And finally, deploy it
    git push -f

# Deleting all the old credentials

It will take a minute or two for the new config vars to kick in. You can tell when by logging into the bors-ng dashboard in
a separate tab, reloading the GitHub App settings page, and seeing that the new client secret gets used.

Finally, delete the old Client Secret and Private Key. This is the important part! A bad actor might have the old ones,
and until you delete them, they might still work!
