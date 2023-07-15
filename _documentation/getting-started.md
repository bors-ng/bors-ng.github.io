---
title: Getting started
description: How to set up bors-ng on your GitHub repo
layout: page
redirect_from: /getting-started/
---

# Setting up bors

Bors-NG does not replace CI tools like Travis CI or Github Actions;
it's just a frontend that implements a particular workflow on top of it.
So the first step of setting up bors is setting something up to automatically run your tests.

The general steps to setup bors-ng are:

* Enable some form of CI system
    * Your CI system should build the "staging" and "trying" branches, but should not build the "staging.tmp", "trying.tmp", or "staging-squash-merge.tmp" branches. The "staging.tmp" branch is used for bors r+ builds, the "trying.tmp" branch is used for bors try builds, and the "staging-squash-merge.tmp" branch is used only when the `use_squash_merge` feature is enabled.
    * Your CI system should be able to run the contents of a particular branch and report its results using a GitHub Status notification (the little <abbr style="color:orange" title="The build is in progress">&bull;</abbr>, <abbr style="color:green" title="Build succeeded">&#10003;</abbr>, or <abbr style="color:red" title="Build failed">&times;</abbr> next to a commit in the commits list). Newer CI systems, like Travis, AppVeyor, and CircleCI will do this by default. Jenkins and BuildBot have plugins for it.
* Set up an instance of the bors-ng app.
* Create a `bors.toml` in your repo with appropriate configuration.
    * This will specify what CI systems Bors-NG should use, along with other metadata like timeouts.
    * The most important value is `status`, which specifies which GitHub Statuses it uses to determine a successful or failed build. Its value depends on the CI system you are using.
    * **Note:** that bors reads bors.toml from the pull requests it's merging, not the one in master, so changes to the file get checked before they land. You can therefore verify whether bors is working by using `bors r+` to try and land the PR that enables it!
* Once this is done, you should be able to use bors to merge, as discussed in the section below!

## Detailed instauctions for self-hosting

### Step 1: Register a new GitHub App

The first step is to [register a new GitHub App] on the GitHub web site.

[Register a new GitHub App]: https://github.com/settings/apps

#### App settings

The *GitHub App name*, *description*, and *homepage URL* are irrelevant, though I suggest pointing the homepage at the dashboard page.

The *user authorization callback URL* should be at `<DASHBOARD URL>/auth/github/callback`.

Leave the *setup URL* blank.

The *webhook URL* should be at `<DASHBOARD URL>/webhook/github`.

The *webhook secret* should be a randomly generated string. The `mix phx.gen.secret` command will work awesomely for this. Keep this handy to specify the same value in the bors configuration (you can also edit this value later if you need to).

#### Required GitHub App permissions

#####  Permission summary

<details><summary>Click here to view a screenshot</summary>

<img style="max-width:100%" src="/permissions-screenshot.png">

</details>

For each of these sections, set the following overall section permissions and check the following webhook event checkboxes. Explanations for why bors-ng needs each of these permissions are below.

- *Repository metadata*: Read-only (no choice)
  - *Repository* (Repository created, deleted, publicized, or privatized)
- *Repository administration*: No access
- *Commit statuses*: Read & write
  - *Status* (Commit status updated from the API)
- *Deployments*: No access
- *Issues*: Read & write
  - *Issue comment* (Issue comment created, edited, or deleted)
- *Pages*: No access
- *Pull requests*: Read & write
  - *Pull request* (Pull request opened, closed, reopened, edited, assigned, unassigned, review requested, review request removed, labeled, unlabeled, or synchronized)
  - *Pull request review* (Pull request review submitted, edited, or dismissed)
  - *Pull request review comment* (Pull request diff comment created, edited, or deleted)
- *Repository contents*: Read & write
  - (no checkboxes)
- *Single file*: No access
- *Repository projects*: No access
- *Organization members*: Read-only
  - *Team* (Team is created, deleted, edited, added to/removed from a repository)
  - *Member* (Collaborator added to, removed from, or has changed permissions for a repository)
  - *Membership* (Team membership added or removed)
  - *Organization* ( User invited to, added to, or removed from an organization)
- *Organization projects*: No access
- *Checks*: Read & Write
  - *Check run* (Check run created from the API)
  - *Check suite* (Check suite created from the API)

##### Permission explanations

*Repository metadata* will be read-only. Must be set to receive *Repository* events to automatically remove entries from our database when a repo is deleted.

*Commit statuses* must be set to *Read & write* to report a testing status (this is the older version). Also must get *Status* events to integrate with CI systems that report their status via GitHub.

*Issues* must be set to *Read & write* because pull requests are issues. *Issue comment* events must be enabled to get the "bors r+" comments. If *Issues* is set to Read-only, repos will end up with pull requests that are marked as simultaneously merged and opened.

*Pull requests* must be set to *Read & write* to be able to post pull request comments. Also, must receive *Pull request* events to be able to keep the dashboard working, and must get *Pull request review* and *Pull request review comment* events to get those kinds of comments.

*Repository contents* must be set to *Read & write* to be able to create merge commits.

*Checks* must be set to *Read & write* to report a testing status (this is the newer version). Also must get *Check run* events to integrate with CI systems that report their status via GitHub.

*Organization members* must be set to *Read only* to synchronize repository contributors and bors reviewers.

#### After you click the "Create" button

GitHub will send a "ping" notification to your webhook endpoint. Since bors is not actually running yet, that will fail. This is expected.

You'll need the following values from your GitHub App for configuring bors-ng:

- Private key (generate one and download the file)
- OAuth credentials
- ID (appears beneath the app logo and "Owned by" in the right hand column)

#### Internal app?

GitHub Apps can be set as "Internal" or "External".
When the App is set to be internal,
then whichever organization/user it belongs to will be the only one allowed to install it.

This setting can be chosen while first creating the app, or it can be changed afterward at one of these URLs (the switch is on the bottom of the page):

* If the app is owned by an organization: `https://github.com/organizations/<ORGANIZATION>/settings/apps/<APP NAME>/advanced`
* If the app is owned by a user: `https://github.com/settings/apps/<APP NAME>/advanced`

If an "External" app is installed on any external repositories,
then the "Make Internal" button will be grayed out.

### Step 2: Set up the server

bors-ng is written in the [Elixir] programming language,
and it uses [PostgreSQL] as the backend database.
Whatever machine you plan to run it on needs to have both of those installed.

[Elixir]: https://elixir-lang.org/
[PostgreSQL]: https://postgresql.org/
[docs on how to deploy phoenix apps]: https://hexdocs.pm/phoenix/deployment.html

bors-ng is built on the Phoenix web framework, and they have [docs on how to deploy phoenix apps] already. Where you deploy will determine what the dashboard URL will be, which is needed in the previous steps, so this decision needs to be made before you can set up the GitHub App.

You'll need to edit the configuration with a few bors-specific variables.

### Deploying on [Heroku] (and other 12-factor-style systems)

[Heroku]: https://heroku.com/

The config file in the repository is already set up to pull the needed information from the environment, so you can configure bors by setting the right env variables and deploy the app from this repository into Heroku:

Run these commands to deploy on Heroku:

**Note**: The `GITHUB_INTEGRATION_ID` is now called the App ID on GitHub.

    $ heroku create --buildpack "https://github.com/HashNuke/heroku-buildpack-elixir.git" bors-app
    $ heroku buildpacks:add https://github.com/gjaldon/heroku-buildpack-phoenix-static.git
    $ heroku addons:create heroku-postgresql:hobby-dev
    $ heroku config:set \
        MIX_ENV=prod \
        POOL_SIZE=18 \
        PUBLIC_HOST=bors-app.herokuapp.com \
        ALLOW_PRIVATE_REPOS=true \
        COMMAND_TRIGGER=bors \
        SECRET_KEY_BASE=<SECRET1> \
        GITHUB_CLIENT_ID=<OAUTH_CLIENT_ID> \
        GITHUB_CLIENT_SECRET=<OAUTH_CLIENT_SECRET> \
        GITHUB_INTEGRATION_ID=<ISS> \
        GITHUB_INTEGRATION_PEM=`base64 -w0 priv.pem` \
        GITHUB_WEBHOOK_SECRET=<SECRET2> \
        [BORS_LOG_LEVEL=<debug|info|warn|...>]
    $ git push heroku master
    $ heroku run POOL_SIZE=1 mix ecto.migrate

*WARNING*: bors-ng stores some short-term state inside the `web` dyno (it uses a sleeping process to implement delays, specifically).
It can recover the information after restarting, but it will not work correctly with Heroku's replication system.
If you need more throughput than one dyno can provide, you should deploy using a system that allows Erlang clustering to work.


#### Deploying using [Docker] (and compatible container orchestration systems)

[Docker]: https://docker.com/

Pre-built Docker images are available at [Docker Hub](https://hub.docker.com/r/borsng/bors-ng/) for the current `master` (as `bors-ng:latest`).

The Dockerfile in the project root can be used to build the image yourself.
It relies on [multi-stage builds](https://docs.docker.com/engine/userguide/eng-image/multistage-build/) as introduced in Docker 17.05,
to generate a slim image without the Erlang, Elixir and NodeJS development tools.

Most of the important configuration options should be set at runtime using environment variables, not unlike the Heroku instructions.
All the same recommendations apply, with some extra notes:

- `ELIXIR_VERSION` can be set as a build-time argument. Its default value is defined in the [Dockerfile](Dockerfile).
- `ALLOW_PRIVATE_REPOS` must be set at both build and run times to take effect. It is set to ` true` by default.
- `DATABASE_URL` _must_ contain the database port, as it will be used at container startup to wait until the database is reachable. [The format is documented here](https://hexdocs.pm/ecto/Ecto.Repo.html#module-urls). For using MySQL in the docker image, use a mysql scheme url: `-e DATABASE_URL="mysql://root:<secret>@db:3306/bors_ng"` in conjunction with `BORS_DATABASE=mysql`
- `DATABASE_TIMEOUT` may be set higher than the default of `15_000`(ms). This may be necessary with repositories with a very large amount of members.
- `DATABASE_PREPARE_MODE` can be set to to `unnamed` to disable prepared statements, [which is necessary when using a transaction/statement pooler, like pgbouncer](https://github.com/elixir-ecto/postgrex#pgbouncer). It is set to `named` by default.
- `BORS_DATABASE` can be set to `mysql` to switch the Docker container to MySQL
- The database schema will be automatically created and migrated at container startup, unless the ` DATABASE_AUTO_MIGRATE` env. var.
  is set to `false`. Make that change if the database state is managed externally, or if you are using a database that cannot safely handle
  concurrent schema changes (such as older MariaDB/MySQL versions).
- Database migrations can be manually applied from a container using the `migrate` release command. Example:
  `docker run borsng/bors-ng:latest /app/bors/bin/bors migrate`.
  Unfortunately other `mix` tasks are not available, as they cannot be run from compiled releases.
- The `PORT` environment variable is set to `4000` by default.
- `GITHUB_URL_ROOT_API` and `GITHUB_URL_ROOT_HTML` should allow you to connect bors-ng to an instance of GitHub Enterprise.
  Note: I've never actually used GitHub Enterprise, so I'm kinda guessing about what you'd need here.
- `BORS_LOG_LEVEL` allows you to set the log level at runtime for bors-ng.
  The allowed values are the usual Elixir `Logger` levels, e.g. `info`, `debug`, `warn`, etc.
  Defaults to `info` if not set.

      docker create --name bors --restart=unless-stopped \
          -e PUBLIC_HOST=app.bors.tech \
          -e SECRET_KEY_BASE=<secret> \
          -e GITHUB_CLIENT_ID=<secret> \
          -e GITHUB_CLIENT_SECRET=<secret> \
          -e GITHUB_INTEGRATION_ID=<secret> \
          -e GITHUB_INTEGRATION_PEM=<secret> \
          -e GITHUB_WEBHOOK_SECRET=<secret> \
          -e DATABASE_URL="postgresql://postgres:<secret>@db:5432/bors_ng" \
          -e DATABASE_USE_SSL=false \
          -e DATABASE_AUTO_MIGRATE=true \
          -e COMMAND_TRIGGER=bors \
          [-e BORS_LOG_LEVEL=<debug|info|warn|...>] \
          borsng/bors-ng
      docker start bors

#### Deploying on your own cluster

Your configuration can be done by modifying `config/prod.secret.exs`.

### Optional step 3: make yourself an admin

bors-ng offers a number of special functions for "administrator" users, including diagnostics and the ability to open a repo dashboard without being a reviewer.

However, there's no UI for adding admins; you'll have to go into Postgres yourself to do it. There's two ways to do that:

You can do it from the iex prompt, like this:

    shell$ iex -S mix # or `heroku run bash -c "POOL_SIZE=1 iex -S mix"`
    iex> me = BorsNG.Database.Repo.get_by! BorsNG.Database.User, login: "<your login>"
    iex> BorsNG.Database.Repo.update! BorsNG.Database.User.changeset(me, %{is_admin: true})

You can do it from a PostgreSQL prompt like this:

    postgres=# \c bors_dev -- or bors_prod
    bors_dev=# update users set is_admin = true where login = '<your login>';

## Detailed instructions for various CI systems

### Setting up Travis

For travis, the configuration to limit to particular branches should look something like this:

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

Next, create a `bors.toml`. It should look something like this:

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

### Configuring CircleCI

CircleCI configuration should look something like this:

```yaml
workflows:
  build-deploy:
    jobs:
      - test:
          # run full test cycle for 'merge' or 'try'
          filters:
            branches:
              only: 
                - staging
                - trying
      - publish:
          requires:
            - test
          # only publish site changes on 'merge'
          filters:
            branches:
              only: staging
```

Next, install the bors application as described above.

Next, create a `bors.toml` file which specifies the job names or workflow name to require:

```toml
#CircleCI using GitHub Status
status = [
  "ci/circleci: jobname"
  
]

#CircleCI using GitHub Checks
status = [
  "workflow-name" 
]
```

### Configuring Github Actions

First, configure a workflow that builds Rust that is configured to run on pushs to the `main`, `staging`, and `trying` branches. As an example, for a Rust project, you might have a `.github/workflows/rust.yml` file like this:

```yaml
name: Rust

on:
  push:
    branches: [main, staging, trying]
  pull_request:
    branches: [main]

env:
  CARGO_TERM_COLOR: always

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v2
      - name: Build
        run: cargo build --verbose
      - name: Run tests
        run: cargo test --verbose
```

Next, install the bors application as described above.

Next, create a `bors.toml` file which specifies the status names. To figure out what name to use, use the name of the *job* (`Build`, in our example above). You can find that by looking at the "status" marks on your PR. It should say something like `Rust / Build (...)`, in which case you want the `Build` (the `Rust` part comes from the name of the workflow, and that is not what you want).

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

  * When using matrix or generated job names, the configuration might be hard to nail down and bors times out due to missing checks. In sitations like these, it might make sense to have a 'dummy' CI job that depends on all the jobs you want bors to check. An example could look like this:

{% raw  %}

    ```yaml
    # We need some "accummulation" job here because bors fails (timeouts) to
    # listen on matrix builds.
    # Hence, we have some kind of dummy here that bors can listen on
    ci-success:
      name: CI
      if: ${{ success() }}
      needs:
        - doc
        - test
      runs-on: ubuntu-latest
      steps:
        - name: CI succeeded
          run: exit 0
    ```

{% endraw %}

    And in your bors.toml, you then just depend on that "CI" status and bors should be able to find it:

    ```toml
    status = [
      "CI"
    ]
    ```

You can also get help on [our forum](https://forum.bors.tech). We won't chew you out if it turns out to be one of those problems after all.
