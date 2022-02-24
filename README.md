# CryptoBot

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

FB Messenger settings:
1. Create a page, app (messenger app)
2. Add webhook links in Messenger app and get token.
3. Add those tokens in config.exs file
   CRYPTO_TOKEN
   FB_MESSENGER_TOKEN
   PAGE_ID
   ACCESS_TOKEN
Refer: https://developers.facebook.com/docs/messenger-platform/getting-started

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix
