defmodule CryptoBot.FbMessenger do

  alias CryptoBot.CoinGeckoApi
  
  def error_msg(msg), do: format_data("error", msg)

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
          {:error, msg} -> format_data("error", msg["error"])
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
    title = "Market data as follows:"
    prices = Enum.map(data["prices"], fn price ->
      "$#{round_value(List.last(price))}"
    end) |> Enum.join(", \n")
    "Last 14 days price as follows: \n #{prices}" |> text_msg
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
    coin_id   = data["id"]
    market_data = data["market_data"]
    price = market_data["current_price"]["usd"]
    market_cap_rank = data["market_cap_rank"]
    price_change_24h = round_value(market_data["price_change_24h"], 5)
    percentage_change_7d = round_value(market_data["price_change_percentage_7d"], 5)
    percentage_change_14d = round_value(market_data["price_change_percentage_14d"], 5)
     
    title = "#{coin_name}, price: $#{price} rank: #{market_cap_rank}"
    subtitle = "24h $ change: $#{price_change_24h}, 7d % change: #{percentage_change_7d}%, 14d % change: #{percentage_change_14d}%"
    menus = [buttons_menu(%{"name" => "Price History(14d)", "payload" => "market:#{coin_id}" })]
    elements = [element_format(menus, title, subtitle)]
    |> attachment_format
    |> attachment_msg
  end

  def format_data("error", msg) do
    msg |> text_msg
  end

  def format_data(_type, _data) do
    help_text
  end

  def help_text do
    title = "Our features are restricted to few keywords:"
    menu = []
    menu = menu ++ [%{"name" => "top:10", "payload" => "top:10" }]
    menu = menu ++ [%{"name" => "price:iotex", "payload" => "price:iotex" }]
    menu = menu ++ [%{"name" => "market:ripple", "payload" => "market:ripple" }]
    menus = Enum.map(menu, &(buttons_menu(&1))) 
    elements = [element_format(menus, title)]
    |> attachment_format
    |> attachment_msg
  end

  def fetch_user_info(psid) do
    access_token = Application.get_env(:crypto_bot, :access_token)
    "https://graph.facebook.com/#{psid}?fields=first_name,last_name&access_token=#{access_token}"

  end

  @spec attachment_format(list()) :: map()
  defp attachment_format(elements) do
    %{
      type: "template",
      payload: %{
        template_type: "generic",
        elements: elements
      }
    }
  end

  @spec buttons(map()) :: map()
  defp buttons(coin) do
    %{      
      type: "postback",
      title: coin["name"],
      payload: "price:#{String.downcase(coin["id"])}"
    }
  end

  @spec buttons_menu(map()) :: map()
  def buttons_menu(coin) do
    %{      
      type: "postback",
      title: coin["name"],
      payload: coin["payload"]
    }
  end

  @spec element_format(list(), String.t) :: map()
  defp element_format(buttons, title \\ "Top Coins:") do
    %{ title: title, buttons: buttons }
  end
  
  @spec element_format(list(), String.t, String.t) :: map()
  defp element_format(buttons, title, subtitle) do
    %{ title: title, subtitle: subtitle, buttons: buttons }
  end

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

  def round_value(value, precision \\ 10), do: value |> Decimal.from_float |> Decimal.round(precision)



end
