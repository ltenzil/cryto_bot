defmodule CryptoBot.FbMessenger do

  alias CryptoBot.CoinGeckoApi
  
  def received_msg(input) do

  end

  def send_msg(message) do

  end

  def reply_for(term) do
    term
    |> analyse_input
    |> fetch_data
  end

  def analyse_input(query) do 
    String.split(query, ":")
  end
    
  def fetch_data([type | term]) do
    case Enum.member?(["price", "market", "top"], type) do
      true -> 
        case call_apis(type, term) do
          {:ok, data} -> format_data(type, data)
          _ -> help_text
        end
      _ -> 
        help_text
    end
  end


  def call_apis(type, term) do
    case String.downcase(type) do
      "price" -> CoinGeckoApi.info(term)
      "market" -> CoinGeckoApi.market_data(term)
      "top" -> CoinGeckoApi.top_five
      _ -> {:error, msg: "Try price:iotex or top five or market:iotex" }
    end
  end

  def format_data("market", data) do
    "Market data as follows:"
  end

  def format_data("top", data) do
    coin_batches = Enum.map(data, fn coin ->
      %{
        type: "postback",
        title: coin["name"],
        payload: "price:#{String.downcase(coin["symbol"])}"
      }
    end) 
    quick_replies(coin_batches, "Top five coins:")
    # elements = Enum.map(coin_batches, fn coins ->
    #   %{ title: "Coin batches:", buttons: coins }
    # end)

    # %{
    #   type: "template",
    #   payload: %{
    #     template_type: "generic",
    #     elements: elements
    #   }
    # }
    # |> attachment_msg
  end

  def attachment_format(elements) do
    %{
      type: "template",
      payload: %{
        template_type: "generic",
        elements: elements
      }
    }
  end
 
  def format_data("price", data) do
    coin_name = data["name"]
    market_cap_rank = data["market_cap_rank"]
    market_data = data["market_data"]
    price = market_data["current_price"]["usd"]
    max_supply = market_data["max_supply"]
    total_supply = market_data["total_supply"]
    price_change_24h = market_data["price_change_24h"]
    circulating_supply = market_data["circulating_supply"]
    price_change_percentage_24h = market_data["price_change_percentage_24h"]
    price_change_percentage_7d = market_data["price_change_percentage_7d"]
    price_change_percentage_14d = market_data["price_change_percentage_14d"]
     
    "#{coin_name}, current price: #{price} $, \n 
      market cap rank: #{market_cap_rank}, \n
      total supply: #{total_supply},\n max supply: #{max_supply}, \n
      24h $ change: #{price_change_24h} $, \n
      24h % change: #{price_change_percentage_24h} %, \n
      7d % change: #{price_change_percentage_7d} %,  \n
      14d % change: #{price_change_percentage_14d} %"
    |> text_msg
  end

  def format_data(_type, _data) do
    help_text
  end

  def help_text do
    "Our features are restricted to few keywords, 'top five', price:coin_name, market:coin_name
     example: 
     top:five
     price:iotex
     market:shiba"
    |> text_msg
  end

  def fetch_user_info(psid) do
    access_token = Application.get_env(:crypto_bot, :access_token)
    "https://graph.facebook.com/#{psid}?fields=first_name,last_name&access_token=#{access_token}"

  end

  def text_msg(msg), do: Jason.encode!(%{text: msg})
  def attachment_msg(msg), do: Jason.encode!(%{attachment: msg})
  def quick_replies(msg, title) do
    %{ messaging_type: "RESPONSE",
       message: %{
        text: title,
        quick_replies: msg
      }
    }
  end



end
