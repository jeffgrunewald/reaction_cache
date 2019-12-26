# ReactionCache

## The API

The ReactionCache is a microservice cache for tracking user reactions to content items.
It is an illustrative exercise and is not a production-grade deployable application.

The cache is based on ETS (Erlang Term Storage) to maximize simplicity while still providing
atomic write operations and allowing for concurrent reads. The table is wrapped in a GenServer
to manage access to writing to the table but the read operations query the table directly
to allow for fast concurrent access to existing records.

### Adding a reaction
Reactions can be added to the cache with the function `ReactionCache.add_reaction/3` where
the arguments are the `content_id` of the content being reacted to, the `user_id` of the user
providing the reaction, and the `reaction_type` (a string representing an emoji).

### Removing a reaction
Reactions can be removed by calling the `ReactionCache.remove_reaction/3` and providing the same
arguments as to the `add_reaction/3` function. This allows users to remove specific reactions to
specific content without interfering with their other reactions to the same or different content,
or to any other users' reactions.

### Querying the reaction counts
Reactions to any content item can be queried by the `ReactionCache.get_reactions/1` function where
the argument is the `content_id` of the desired content to retrieve a list of reaction counts. A
map is returned containing every reaction type that has been recorded for the given content and a
count of the number of unique users who provided each reaction type without subsequently removing
the reaction.

### Querying via the Phoenix web service
The cache service is accessible over HTTP as a JSON API provided by a minimal Phoenix server. The
`/api/reaction` endpoint accepts POST requests and expects a JSON payload to contain string values
for `type`, `action`, `content_id`, `user_id`, and `reaction_type`. The action should be either `add`
or `remove` to determine the interaction with the cache. An incomplete or incompatible request will
return a 400 error with a help message suggesting the correct values to supply in the request payload.

The counts for each reaction can be retrieved by sending a GET request to the `/api/reaction_counts/:content_id`
endpoint. The return value is a JSON payload containing the `content_id` for reference and a map of
the reactions and their counts. Querying against a content_id that has no reactions (i.e. has no entries
recorded in the cache) will result in an empty 404 response.

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

  * Official website: http://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Mailing list: http://groups.google.com/group/phoenix-talk
  * Source: https://github.com/phoenixframework/phoenix
