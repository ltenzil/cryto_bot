defmodule CryptoBotWeb.ChatController do
  use CryptoBotWeb, :controller

  def webhook(conn, %{"hub.mode" => mode, "hub.verify_token" => token, "hub.challenge" => challenge}) do
    verify_token = Application.get_env(:crypto_bot, :app_token)

    if (mode == "subscribe" and token == verify_token) do
      IO.inspect("Webhook verified")
      send_resp(conn, 200, challenge)
    else
      send_resp(conn, 403, "Unauthorized")
    end
  end

  def webhook(conn, _params) do
    send_resp(conn, 403, "Unauthorized")
  end
end
