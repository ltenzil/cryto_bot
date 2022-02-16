defmodule CryptoBotWeb.ChatController do
  use CryptoBotWeb, :controller

  alias CryptoBot.FbMessenger
  alias CryptoBot.FbApi

  def webhook(conn, %{"hub.mode" => mode, "hub.verify_token" => token, "hub.challenge" => challenge}) do
    verify_token = Application.get_env(:crypto_bot, :app_token)

    if (mode == "subscribe" and token == verify_token) do
      IO.inspect("Webhook verified")
      send_resp(conn, 200, challenge)
    else
      send_resp(conn, 403, "Unauthorized")
    end
  end

  def incoming_message(conn, params) do
    if (params["object"] == "page") do
      Enum.each(params["entry"], fn entry ->
        event = Map.get(entry, "messaging") |> Enum.at(0)
        %{"message" => %{"text" => text}, "sender" => %{"id" => sender_psid}} = event
        send_message(sender_psid, FbMessenger.reply_for(text))
      end)
      send_resp(conn, 200, "EVENT_RECEIVED")
    else
      send_resp(conn, 404, "NOT_FOUND")
    end
  end

  defp send_message(psid, message) do
    FbApi.send_msg(psid, message)
  end

end
