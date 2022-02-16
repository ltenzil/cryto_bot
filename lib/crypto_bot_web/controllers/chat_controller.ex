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
        IO.inspect(params)
        event = Map.get(entry, "messaging")
        |> Enum.at(0)
        |> handle_event
        send_message(event[:sender_psid], event[:text])
      end)
      send_resp(conn, 200, "EVENT_RECEIVED")
    else
      send_resp(conn, 404, "NOT_FOUND")
    end
  end

  defp handle_event(%{"postback" => postback, "recipient" => recipient, "sender" => sender} = event) do    
    %{ text: postback["payload"], sender_psid: sender["id"], recipient_id: recipient["id"] }
  end

  defp handle_event(%{"message" => message, "sender" => sender} = event) do
    %{ text: message["text"], sender_psid: sender["id"], recipient_id: nil }
  end

  defp send_message(psid, message) do
    reply = FbMessenger.reply_for(message)
    FbApi.send_msg(psid, reply)
  end

end
