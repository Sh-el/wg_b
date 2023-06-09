defmodule WgWeb.RequestLimiter.Plug do
  @moduledoc """
  A Plug module for limiting the rate of incoming requests using a GenServer.

  This Plug checks with a `WgWeb.RequestLimiter.Server` GenServer to see if the
  current request should be allowed based on the configured rate limit. If there
  are no tokens available, the Plug will respond with an HTTP status code of 429
  (Too Many Requests).

  Usage:
  1. Add the plug to your Phoenix router in the pipeline where you want it to run.
     e.g. pipeline :api do
            plug :accepts, ["json"]
            plug WgWeb.RequestLimiter.Plug
            plug :fetch_session
            ...
         end
  2. Configure the `WgWeb.RequestLimiter.Server` to your desired rate limit.

  """
  use WgWeb, :controller
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    case WgWeb.RequestLimiter.Server.get_token() do
      :ok ->
        conn

      {:error, :no_tokens} ->
        conn
        |> put_status(429)
        |> json(%{error: "Too Many Requests"})
        |> halt()
      end
  end
end
