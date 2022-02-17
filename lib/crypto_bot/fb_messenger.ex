defmodule CryptoBot.FbMessenger do

  alias CryptoBot.CoinGeckoApi
  import CryptoBot.Message

  @spec reply_for(String.t) :: String.t
  def reply_for(term) do    
    [type | query] = analyse_input(term)
    fetch_data(type, query)
  end

  def error_msg(msg), do: format_data("error", msg)

  def fetch_data("", _),   do: help_text
  def fetch_data(_, ""),   do: help_text
  def fetch_data(_, [""]), do: help_text
  def fetch_data(_, []),   do: help_text
  def fetch_data(type, [term]) do
    case Enum.member?(["price", "market", "top"], type) do
      true -> 
        case call_apis(type, term) do
          {:ok, data} -> format_data(type, data)
          {:error, error} -> format_data("error", error[:msg])
        end
      _ -> 
        help_text
    end
  end

  # @spec call_apis(String.t, String.t) ::
  def call_apis(type, term) do
    case String.downcase(type) do
      "price" ->  CoinGeckoApi.info(term)
      "market" -> CoinGeckoApi.market_data(term)
      "top" ->    CoinGeckoApi.toppers(term)
      _ ->        {:error, [msg: 'Try price:iotex or top:5 or market:iotex']}
    end
  end

  def format_data("top", data) do
    Enum.map(data, &(price_button(&1)))
    |> Enum.chunk_every(3)
    |> Enum.map(&(element_format(&1)))
    |> attachment_format
  end
  
  def format_data("market", data) do
    prices = Enum.map(data["prices"], fn price ->
      "$#{round_value(List.last(price))}"
    end) |> Enum.join(", \n")
    text_msg("Last 14 days price as follows: \n #{prices}")
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
    menus = [buttons(%{"name" => "Price History(14d)", "payload" => "market:#{coin_id}" })]
    elements = [element_format(menus, title, subtitle)]
    |> attachment_format
  end

  def format_data("error", msg), do: text_msg(msg)
  
  def format_data(_type, _data), do: help_text

  defp round_value(value, precision \\ 10) do 
    value |> Decimal.from_float |> Decimal.round(precision)
  end

end
