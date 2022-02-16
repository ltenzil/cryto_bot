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
    case Enum.member?(["price", "market", "top five"], type) do
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
      "top five" -> CoinGeckoApi.top_five
      _ -> {:error, msg: "Try price:iotex or top five or market:iotex" }
    end
  end

  def format_data("market", data) do
    "Market data as follows:"
  end

  def format_data("top five", data) do
    response = "Top five coins as follows: \n"
    coins = Enum.map(data, fn coin ->
      %{
        type: "postback",
        title: coin["name"],
        payload: String.downcase(coin["name"])
      }
    end)
    %{ 
      attachment: %{
        type: "template",
        payload: %{
          template_type: "generic",
          elements: [
             %{ title: "Top five coins as follows:", buttons: coins }
          ]
        }
      }
    }
    |> Jason.encode!
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

    "#{coin_name}, its current price is at #{price}, has market cap rank of #{market_cap_rank}, 
      total supply is at #{total_supply} and max supply at #{max_supply}, 
      price_change_24h: #{price_change_24h} $,
      price_change_percentage_24h: #{price_change_percentage_24h} %,
      price_change_percentage_7d: #{price_change_percentage_7d} %,
      price_change_percentage_14d: #{price_change_percentage_14d} %
    "
  end

  def format_data(_type, _data) do
    help_text
  end

  def help_text do
    "Our features are restricted to few keywords, 'top five', price:coin_name, market:coin_name
     example: 
     TopFive
     price:iotex
     market:shiba"
  end

  def fetch_user_info(psid) do
    access_token = Application.get_env(:crypto_bot, :access_token)
    "https://graph.facebook.com/#{psid}?fields=first_name,last_name&access_token=#{access_token}"

  end



end
