defmodule Wg.RequestLimiter.PlugTest do
  use WgWeb.ConnCase
  use ExUnit.Case

  alias WgWeb.RequestLimiter.Server

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "request_limiter" do
    test "returns 200 for successful requests and returns 429 for too many requests", %{conn: conn} do
      tokens = Server.number_tokens()
      Enum.each(1..tokens, fn _ ->
        conn = get(conn, ~p"/ping")
        assert conn.status == 200
      end)

      conn = get(conn, ~p"/cats")
      assert conn.status == 429
    end
  end
end
