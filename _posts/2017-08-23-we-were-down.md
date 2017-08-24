---
title: Downtime from 5:47 PM to 2:00 AM UTC the next day
date: 2017-09-03 02:00:00
summary: We screwed up and pushd a broken pull request into production
categories: pants-on-head-stupid, downtime, retrospective
---

We screwed up and pushed [a broken pull request](https://github.com/bors-ng/bors-ng/pull/275) into production.
After noticing an elevated number of crashing pull requests,
I found the difference between the unit test harness and production that allowed it to get that far.

Basically, every time you `r+`-ed a pull request, it would not actually start anything.
In the "History" tab on the dashboard, this would show up as a crash dump:

```
{%UndefinedFunctionError{arity: 2, exports: nil,
  function: :fetch, module: BorsNG.Database.User,
  reason: "BorsNG.Database.User does not implement the Access behaviour"},
 [{BorsNG.Database.User, :fetch,
   [%BorsNG.Database.User{__meta__: #Ecto.Schema.Metadata<:loaded, "users">,
     id: 1, inserted_at: ~N[2017-03-23 19:38:11.900098],
     is_admin: true, login: "notriddle",
     projects: #Ecto.Association.NotLoaded<association :projects is not loaded>,
     updated_at: ~N[2017-03-25 01:13:22.443983],
     user_xref: 1593513}, :login], []},
  {Access, :fetch, 2, [file: 'lib/access.ex', line: 240]},
  {Access, :get, 3, [file: 'lib/access.ex', line: 269]},
  {BorsNG.Worker.Batcher.Message,
   :"-generate_commit_message/2-fun-2-", 3,
   [file: 'lib/batcher/message.ex', line: 83]},
  {Enum, :"-reduce/3-lists^foldl/2-0-", 3,
   [file: 'lib/enum.ex', line: 1755]},
  {BorsNG.Worker.Batcher.Message, :generate_commit_message,
   2, [file: 'lib/batcher/message.ex', line: 81]},
  {BorsNG.Worker.Batcher, :start_waiting_merged_batch, 4,
   [file: 'lib/batcher.ex', line: 294]},
  {BorsNG.Worker.Batcher, :start_waiting_batch, 1,
   [file: 'lib/batcher.ex', line: 270]}]}
```

It was caused by attempting to use [this line of code](https://github.com/bors-ng/bors-ng/pull/275/files#diff-7c518cd3df1fb5156f4e6ad3843adeaeR83):

```elixir
author = link.patch.author[:login]
```

When `author` is `nil`,
using the Access syntax `[:login]` will simply result in `nil` again as the result,
while when a plain map is passed in, it looks up the item in the map and returns the result.
This is why the plain dot lookup syntax was used.

You may have noticed that the term "plain map" was used;
when a [struct] is passed in,
it will not support the `[]` syntax by default and will complain about the Access protocol not being implemented.

[struct]: https://elixir-lang.org/getting-started/structs.html

The integration test, which would have tested this, left the `author` field unset,
so it was always `nil`.

The unit test case that was supposed to check this used a plain map instead of an instance of a `User` struct,
so the Access syntax worked rather than throwing an error.

Oddly enough, it did not get caught by Dialyzer.

### Conclusions?

[Integration tests], where the actual GitHub API gets involved, need to happen.
That would've caught this.
It's doable, but not implemented because writing a test suite that has to run with both real GitHub and real Bors-NG are going to be complicated.
