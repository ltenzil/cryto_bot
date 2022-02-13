defmodule CryptoBot.Repo do
  use Ecto.Repo,
    otp_app: :crypto_bot,
    adapter: Ecto.Adapters.Postgres
end
