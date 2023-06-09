defmodule WgWeb.CatControllerTest do
  use WgWeb.ConnCase

  import Wg.CatsFixtures

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    @attrs [
      %{name: "Tihon", color: "red & white", tail_length: 15, whiskers_length: 12},
      %{name: "Masya", color: "black", tail_length: 10, whiskers_length: 8},
      %{name: "Pushok", color: "red", tail_length: 12, whiskers_length: 9},
      %{name: "Barsik", color: "red", tail_length: 14, whiskers_length: 11},
      %{name: "Sima", color: "white", tail_length: 8, whiskers_length: 7}
    ]

    @valid_query_params %{attribute: "name", order: "asc", offset: 2, limit: 1}
    @valid_query_params_not_all %{offset: 1, limit: 1}
    @invalid_query_params %{invalid: "invalid", order: "invalid", offset: -2, limit: "invalid"}

    test "lists all cats for empty", %{conn: conn} do
      conn = get(conn, ~p"/cats")
      assert json_response(conn, 200) == []
    end

    test "lists all cats for non empty data", %{conn: conn} do
      cats_fixture(@attrs)
      conn = get(conn, ~p"/cats")
      data = json_response(conn, 200)
      assert length(data) == length(@attrs)
    end

    test "lists cats with valid params for non empty data", %{conn: conn} do
      cats_fixture(@attrs)
      conn = get(conn, ~p"/cats", @valid_query_params)

      [%{"name" => "Pushok", "color" => "red", "tail_length" => 12, "whiskers_length" => 9}] =
        data = json_response(conn, 200)

      assert length(data) == 1
    end

    test "lists cats with valid params not all params for non empty data", %{conn: conn} do
      cats_fixture(@attrs)
      conn = get(conn, ~p"/cats", @valid_query_params_not_all)

      [%{"color" => "black", "name" => "Masya", "tail_length" => 10, "whiskers_length" => 8}] =
        data = json_response(conn, 200)

      assert length(data) == 1
    end

    test "lists cats with invalid params for non empty data", %{conn: conn} do
      cats_fixture(@attrs)
      conn = get(conn, ~p"/cats", @invalid_query_params)

      %{
        "errors" => %{
          "invalid_fields" => ["Invalid fields: [\"invalid\"]"],
          "limit" => ["is invalid"],
          "offset" => ["must be greater or equal to 0 or less than 5"],
          "order" => ["is invalid"]
        }
      } = json_response(conn, 422)
    end
  end

  describe "create cat" do
    @create_attrs %{
      color: :black,
      name: "some name",
      tail_length: 12,
      whiskers_length: 15
    }

    @invalid_attrs %{color: nil, name: nil, tail_length: nil, whiskers_length: nil}
    @invalid_attrs_with_values %{color: :gray, name: 123, tail_length: -5, whiskers_length: 45}

    test "renders cat when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/cat", @create_attrs)
      assert %{"name" => _name} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/cats/")

      assert [
               %{
                 "color" => "black",
                 "name" => "some name",
                 "tail_length" => 12,
                 "whiskers_length" => 15
               }
             ] = json_response(conn, 200)
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/cat", @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}

      conn = post(conn, ~p"/cat", @invalid_attrs_with_values)

      assert %{
               "errors" => %{
                 "color" => _color,
                 "name" => _name,
                 "tail_length" => _tail_length,
                 "whiskers_length" => _whiskers_length
               }
             } = json_response(conn, 422)
    end
  end
end
