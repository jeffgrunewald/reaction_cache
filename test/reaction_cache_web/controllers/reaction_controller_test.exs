defmodule ReactionCacheWeb.ReactionControllerTest do
  use ReactionCacheWeb.ConnCase

  @create_attrs %{
    action: "add",
    content_id: "123-456",
    reaction_type: "fire",
    type: "reaction",
    user_id: "abc-def"
  }
  @delete_attrs %{
    action: "remove",
    content_id: "123-456",
    reaction_type: "fire",
    type: "reaction",
    user_id: "abc-def"
  }
  @invalid_attrs %{action: nil, content_id: nil, reaction_type: nil, type: nil, user_id: nil}

  setup %{conn: conn} do
    ReactionCache.remove_reaction("123-456", "abc-def", "fire")
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "empty cache" do
    test "non-existent content id", %{conn: conn} do
      conn = get(conn, "/api/reaction_counts/123-456")
      assert response(conn, 404) == ""
    end
  end

  describe "create reaction" do
    setup [:setup_remove]

    test "renders reaction when data is valid", %{conn: conn} do
      conn = post(conn, "/api/reaction", @create_attrs)
      assert "Reaction cached!" == response(conn, 201)

      conn = get(conn, "/api/reaction_counts/123-456")

      assert %{
               "content_id" => "123-456",
               "reaction_count" => %{
                 "fire" => 1
               }
             } == json_response(conn, 200)
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, "/api/reaction", @invalid_attrs)

      assert response(conn, 400) ==
               "Unable to save reaction; did you supply a content_id, user_id, and reaction_type?"
    end
  end

  describe "remove reaction" do
    setup [:setup_add]

    test "deletes chosen reaction", %{conn: conn} do
      conn = get(conn, "/api/reaction_counts/123-456")

      assert %{
               "content_id" => "123-456",
               "reaction_count" => %{
                 "fire" => 1
               }
             } == json_response(conn, 200)

      conn = post(conn, "/api/reaction", @delete_attrs)
      assert response(conn, 200) == "Reaction removed!"

      conn = get(conn, "/api/reaction_counts/123-456")
      assert response(conn, 404) == ""
    end
  end

  defp setup_add(_) do
    ReactionCache.add_reaction("123-456", "abc-def", "fire")

    :ok
  end

  defp setup_remove(_) do
    on_exit(fn ->
      ReactionCache.remove_reaction("123-456", "abc-def", "fire")
    end)

    :ok
  end
end
