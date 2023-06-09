defmodule WgWeb.HealthCheckController do
  use WgWeb, :controller

  def ping(conn, _params) do
    text(conn, "Cats Service. Version 0.1")
  end
end
