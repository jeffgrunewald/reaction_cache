defmodule ReactionCacheWeb.ReactionController do
  use ReactionCacheWeb, :controller

  @error_message "Unable to save reaction; did you supply a content_id, user_id, and reaction_type?"

  action_fallback ReactionCacheWeb.FallbackController

  def react(conn, %{"action" => "add"} = params) do
    with content when not is_nil(content) <- Map.get(params, "content_id"),
         user when not is_nil(user) <- Map.get(params, "user_id"),
         reaction when not is_nil(reaction) <- Map.get(params, "reaction_type"),
         :ok <- ReactionCache.add_reaction(content, user, reaction) do
      send_resp(conn, 201, "Reaction cached!")
    else
      _ -> send_resp(conn, 400, @error_message)
    end
  end

  def react(conn, %{"action" => "remove"} = params) do
    with content when not is_nil(content) <- Map.get(params, "content_id"),
         user when not is_nil(user) <- Map.get(params, "user_id"),
         reaction when not is_nil(reaction) <- Map.get(params, "reaction_type"),
         :ok <- ReactionCache.remove_reaction(content, user, reaction) do
      send_resp(conn, 200, "Reaction removed!")
    else
      _ -> send_resp(conn, 400, @error_message)
    end
  end

  def react(conn, _) do
    send_resp(conn, 400, @error_message)
  end

  def get_counts(conn, %{"content_id" => id}) do
    case ReactionCache.get_reactions(id) do
      map when map == %{} ->
        send_resp(conn, 404, "")
      map ->
        json(conn, %{content_id: id, reaction_count: map})
    end
  end
end
