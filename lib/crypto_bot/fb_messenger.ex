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
    
  def fetch_data([type, term]) do
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

  def fetch_data(term), do: help_text


  def call_apis(type, term) do
    case String.downcase(type) do
      "price" -> CoinGeckoApi.info(term)
      "market" -> CoinGeckoApi.market_data(term)
      "top" -> CoinGeckoApi.toppers(term)
      _ -> "Try price:iotex or top:5 or market:iotex" |> text_msg
    end
  end

  def format_data("market", data) do
    "Market data as follows:"
  end

  def format_data("top", data) do
    coin_batches = Enum.map(data, fn coin ->
      %{
        # content_type: "text", for quick replies
        type: "postback", # for buttons
        title: coin["name"],
        payload: "price:#{String.downcase(coin["id"])}"
      }
    end) |> Enum.chunk_every(3)
    # quick_replies(coin_batches, "Top coins:")
    elements = Enum.map(coin_batches, fn coins ->
      %{ title: "Top Coins:", buttons: coins }
    end)
    elements
    |> attachment_format
    |> attachment_msg
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
    change_percentage_24h = market_data["price_change_percentage_24h"]
    change_percentage_7d = market_data["price_change_percentage_7d"]
    change_percentage_14d = market_data["price_change_percentage_14d"]
     
    "#{coin_name}, \n current price: #{price} $
      market cap rank: #{market_cap_rank} \n total supply: #{total_supply}
      max supply: #{max_supply} \n 24h $ change: #{price_change_24h} $
      24h % change: #{change_percentage_24h} % 
      7d % change: #{change_percentage_7d} %
      14d % change: #{change_percentage_14d} %"
    |> text_msg
  end

  def format_data(_type, _data) do
    help_text
  end

  def help_text do
    "Our features are restricted to few keywords, 'top five', price:coin_name, market:coin_name
     example: 
     top:10
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
    %{
      text: title,
      quick_replies: msg
    } |> Jason.encode!
    
  end



end
