defmodule CryptoBot.FbApi do
  alias CryptoBot.BaseApi

  @endpoint "https://graph.facebook.com"  
  @access_token Application.get_env(:crypto_bot, :access_token)

  def send_msg(psid, message) do
    url = @endpoint <> "/v13.0/me/messages?access_token=#{@access_token}"
    body = %{recipient: %{id: psid}, message: message}
    BaseApi.post_data(url, body)
  end

  # def get_user_name(psid) do
  #   @endpoint <> "/#{psid}?fields=first_name,last_name?access_token=#{@access_token}"
  #   |> BaseApi.fetch_data
  # end

  def greet_user do
    body = %{greeting: [
      %{ locale: "default", text: "Hello {{user_first_name}}!" }
    ]}
    @endpoint <> "me/messenger_profile?access_token=#{@access_token}"
    |> BaseApi.post_data(body)
  end

end
