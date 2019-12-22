defmodule ReactionCache do
  @moduledoc """
  Manages the cache and accessor functions for tracking
  user reactions to application content items.
  """

  use GenServer

  def get_reactions(id) do
    :ets.match(:reactions, {{id, :_}, :"$1"})
    |> List.flatten()
    |> Enum.reduce(%{}, &count_reactions/2)
  end

  def add_reaction(content, user, reaction) do
    GenServer.cast(__MODULE__, {:add_reaction, {content, user}, reaction})
  end

  def remove_reaction(content, user, reaction) do
    GenServer.cast(__MODULE__, {:remove_reaction, {content, user}, reaction})
  end

  def start_link(_args) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_args) do
    state = :ets.new(:reactions, [:named_table, :set, read_concurrency: true])

    {:ok, state}
  end

  def handle_cast({:add_reaction, key, value}, state) do
    update_reactions(key, value, &add_user_reaction/2)

    {:noreply, state}
  end

  def handle_cast({:remove_reaction, key, value}, state) do
    update_reactions(key, value, &remove_user_reaction/2)

    {:noreply, state}
  end

  defp count_reactions(item, acc), do: Map.update(acc, item, 1, &(&1 + 1))

  defp update_reactions(key, value, func) do
    key
    |> retrieve_user_reactions()
    |> func.(value)
    |> insert_user_reactions(key)
  end

  defp retrieve_user_reactions(key), do: :ets.match(:reactions, {key, :"$1"}) |> List.flatten()

  defp add_user_reaction(existing, new), do: [new | existing] |> Enum.uniq()

  defp insert_user_reactions(reactions, key), do: :ets.insert(:reactions, {key, reactions})

  defp remove_user_reaction(reactions, value), do: Enum.reject(reactions, &(&1 == value))
end
