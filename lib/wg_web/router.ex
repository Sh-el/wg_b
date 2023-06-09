defmodule WgWeb.Router do
  use WgWeb, :router
  use Plug.ErrorHandler

  def handle_errors(conn, %{reason: %Phoenix.Router.NoRouteError{message: message}}) do
    conn
    |> json(%{errors: message})
    |> halt()
  end

  def handle_errors(conn, %{
        reason: %Plug.Parsers.UnsupportedMediaTypeError{
          media_type: media_type,
          plug_status: plug_status
        }
      }) do
    conn
    |> put_status(plug_status)
    |> json(%{errors: %{media_type: media_type}})
    |> halt()
  end

  def handle_errors(conn, %{
        reason: %Plug.Parsers.ParseError{
          exception: %Jason.DecodeError{position: position, token: _token, data: data},
          plug_status: plug_status
        }
      }) do
    conn
    |> put_status(plug_status)
    |> json(%{errors: %{position: position, data: data}})
    |> halt()
  end

  def handle_errors(conn, %{reason: %{message: message}}) do
    conn |> json(%{errors: message}) |> halt()
  end

  pipeline :api do
    plug WgWeb.RequestLimiter.Plug

    plug(Plug.Parsers,
      parsers: [:urlencoded, :multipart, :json],
      json_decoder: Phoenix.json_library()
    )

    plug :accepts, ["json"]
  end

  scope "/", WgWeb do
    pipe_through(:api)

    get("/ping", HealthCheckController, :ping)
    get("/cats", CatController, :index)
    post("/cat", CatController, :create)
  end
end
