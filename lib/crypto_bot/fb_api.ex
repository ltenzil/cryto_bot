defmodule CryptoBot.FbApi do
  alias CryptoBot.BaseApi

  @endpoint "https://graph.facebook.com/v13.0"  

  def send_msg(psid, %{messaging_type: "RESPONSE", message: payload} = message) do
    access_token = Application.get_env(:crypto_bot, :access_token)
    url  = @endpoint <> "/me/messages?access_token=#{access_token}"
    body = %{recipient: %{id: psid}, messaging_type: "RESPONSE", message: payload}
    BaseApi.post_data(url, body)
  end

  def send_msg(psid, message) do
    access_token = Application.get_env(:crypto_bot, :access_token)
    url  = @endpoint <> "/me/messages?access_token=#{access_token}"
    body = %{recipient: %{id: psid}, message: message}
    BaseApi.post_data(url, body)
  end

end
