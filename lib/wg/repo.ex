defmodule Wg.Repo do
  use Ecto.Repo,
    otp_app: :wg,
    adapter: Ecto.Adapters.Postgres
end
