defmodule WgWeb.CatController do
  use WgWeb, :controller

  alias Wg.Animals.{Cats, Cats.Cat}

  action_fallback WgWeb.FallbackController

  def index(conn, params) do
    with {:ok, cats} <- Cats.get_cats_by_params(params) do
      conn
      |> put_status(:ok)
      |> render(:index, cats: cats)
    end
  end

  def create(conn, cat_params) do
    with {:ok, %Cat{} = cat} <- Cats.create_cat(cat_params) do
      conn
      |> put_status(:created)
      |> render(:show, cat: cat)
    end
  end
end
