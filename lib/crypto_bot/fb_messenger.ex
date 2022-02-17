defmodule CryptoBot.FbMessenger do

  alias CryptoBot.CoinGeckoApi
  
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
    Enum.map(data, &(buttons(&1))) 
    |> Enum.chunk_every(3)
    |> Enum.map(&(element_format(&1)))
    |> attachment_format
    |> attachment_msg
  end

  def format_data("price", data) do
    coin_name = data["name"]
    market_cap_rank = data["market_cap_rank"]
    market_data = data["market_data"]
    price = market_data["current_price"]["usd"]
    price_change_24h = market_data["price_change_24h"]    
    change_percentage_24h = market_data["price_change_percentage_24h"]
    change_percentage_7d = market_data["price_change_percentage_7d"]
    change_percentage_14d = market_data["price_change_percentage_14d"]
     
    "#{coin_name}, \n current price: #{price} $
      market cap rank: #{market_cap_rank}
      24h $ change: #{price_change_24h} $
      24h % change: #{change_percentage_24h} % 
      7d % change: #{change_percentage_7d} %
      14d % change: #{change_percentage_14d} %"
    |> text_msg
  end

  def format_data(:error, msg) do
    msg |> text_msg
  end

  def format_data(_type, _data) do
    help_text
  end

  def help_text do
    title = "Our features are restricted to few keywords:"
    top_ten = %{"name" => "top:10", "payload" => "top:10" } |> buttons_menu
    coin_price = %{"name" => "price:iotex", "payload" => "price:iotex" } |> buttons_menu
    coin_market = %{"name" => "market:ripple", "payload" => "market:ripple" } |> buttons_menu
    buttons = [top_ten, coin_price, coin_market]
    element_format(buttons, title)
    |> attachment_format
    |> attachment_msg
  end

  def fetch_user_info(psid) do
    access_token = Application.get_env(:crypto_bot, :access_token)
    "https://graph.facebook.com/#{psid}?fields=first_name,last_name&access_token=#{access_token}"

  end

  defp attachment_format(elements) do
    %{
      type: "template",
      payload: %{
        template_type: "generic",
        elements: elements
      }
    }
  end

  defp buttons(coin) do
    %{      
      type: "postback",
      title: coin["name"],
      payload: "price:#{String.downcase(coin["id"])}"
    }
  end

  defp buttons_menu(coin) do
    %{      
      type: "postback",
      title: coin["name"],
      payload: coin["payload"]
    }
  end

  defp element_format(buttons, title \\ "Top Coins:"), do: %{ title: title, buttons: buttons }

  defp quick_buttons(coin) do
    # quick_replies(coin_batches, "Top coins:")
    %{
      content_type: "text",
      title: coin["name"],
      payload: "price:#{String.downcase(coin["id"])}"
    }
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
