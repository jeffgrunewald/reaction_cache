defmodule ReactionCacheTest do
  use ExUnit.Case
  import TestHelper

  setup do
    {:ok, cache} = ReactionCache.start_link([])

    on_exit(fn ->
      Process.exit(cache, :kill)
    end)
  end

  test "returns no reactions for new content" do
    assert %{} == ReactionCache.get_reactions("content1")
  end

  describe "add_reaction/3" do
    test "adds user reactions to content" do
      ReactionCache.add_reaction("content1", "user1", "fire")
      ReactionCache.add_reaction("content1", "user2", "fire")

      eventually(fn ->
        assert %{"fire" => 2} == ReactionCache.get_reactions("content1")
      end)
    end

    test "only adds user reactions once per type" do
      ReactionCache.add_reaction("content1", "user1", "fire")
      ReactionCache.add_reaction("content1", "user1", "fire")

      eventually(fn ->
        assert %{"fire" => 1} == ReactionCache.get_reactions("content1")
      end)
    end

    test "adds multiple reaction types per user" do
      ReactionCache.add_reaction("content1", "user1", "fire")
      ReactionCache.add_reaction("content1", "user1", "ice")

      eventually(fn ->
        assert %{"fire" => 1, "ice" => 1} == ReactionCache.get_reactions("content1")
      end)
    end

    test "tracks the same reaction across users" do
      ReactionCache.add_reaction("content1", "user1", "fire")
      ReactionCache.add_reaction("content1", "user2", "fire")

      eventually(fn ->
        assert %{"fire" => 2} == ReactionCache.get_reactions("content1")
      end)
    end

    test "tracks reactions across multiple content items" do
      ReactionCache.add_reaction("content1", "user1", "fire")
      ReactionCache.add_reaction("content2", "user1", "fire")

      eventually(fn ->
        assert %{"fire" => 1} == ReactionCache.get_reactions("content1")
        assert %{"fire" => 1} == ReactionCache.get_reactions("content2")
      end)
    end
  end

  describe "remove_reaction/3" do
    setup do
      ReactionCache.add_reaction("content1", "user1", "fire")
      ReactionCache.add_reaction("content1", "user1", "ice")
      ReactionCache.add_reaction("content2", "user1", "fire")
      ReactionCache.add_reaction("content1", "user2", "fire")
    end

    test "removes a single reaction" do
      ReactionCache.remove_reaction("content1", "user1", "fire")

      eventually(fn ->
        assert %{"fire" => 1, "ice" => 1} == ReactionCache.get_reactions("content1")
      end)
    end

    test "no change when removing a reaction that doesn't exist" do
      ReactionCache.remove_reaction("content1", "user1", "water")

      eventually(fn ->
        assert %{"fire" => 2, "ice" => 1} == ReactionCache.get_reactions("content1")
      end)
    end

    test "removing one user's reaction doesn't impact other users' reactions" do
      ReactionCache.remove_reaction("content1", "user2", "fire")

      eventually(fn ->
        assert %{"fire" => 1, "ice" => 1} == ReactionCache.get_reactions("content1")
      end)
    end

    test "removing reactions from one content item doesn't impact another item" do
      ReactionCache.remove_reaction("content1", "user1", "fire")
      ReactionCache.remove_reaction("content1", "user1", "ice")
      ReactionCache.remove_reaction("content1", "user2", "fire")

      eventually(fn ->
        assert %{"fire" => 1} == ReactionCache.get_reactions("content2")
      end)
    end

    test "removing reactions from empty content item is a no-op" do
      ReactionCache.remove_reaction("content3", "user1", "fire")

      eventually(fn ->
        assert %{} == ReactionCache.get_reactions("content3")
      end)
    end
  end
end
