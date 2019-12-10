defmodule Bloodstone.Repo do
  use Ecto.Repo,
    otp_app: :bloodstone,
    adapter: Ecto.Adapters.Postgres
end
