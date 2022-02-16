defmodule CryptoBot.CoinGeckoApi do
  
  alias CryptoBot.BaseApi

  @endpoint "https://api.coingecko.com/api/v3/"

  @type coin :: String.t
  @type path :: String.t
  @type currency :: String.t
  @type interval :: integer
  @type limit :: integer
  @type options :: list()
  @type success_map :: {:ok, map()}
  @type error_map :: {:error, msg: String.t}

  @spec list_coins :: success_map | error_map
  def list_coins do
    @endpoint <> "coins/list"
    |> BaseApi.fetch_data
  end

  @spec info(coin) :: success_map | error_map
  def info(coin) do
    path    = @endpoint <> "coins/#{coin}"
    options = [params: [localization: false, tickers: false, 
                        community_data: false,
                        developer_data: false, sparkline: false]]    
    BaseApi.fetch_data(path, options)
  end

  
  @spec toppers(limit) :: success_map | error_map
  def toppers(limit \\ 5) do
    per_page = try do
      num = String.to_integer(limit)
      if num <= 10, do: num, else: 5
    rescue
      _ -> 5
    end
    path    = @endpoint <> "coins/markets"
    options = [params: [vs_currency: "usd", order: "market_cap_desc", 
                        per_page: per_page, page: 1]]
    BaseApi.fetch_data(path, options)
  end

  
  @spec market_data(coin, currency, interval) :: success_map | error_map
  def market_data(coin, currency \\ "usd", interval \\ 14) do
    path    = @endpoint <> "coins/#{coin}/market_chart"
    options = [params: [vs_currency: currency, days: interval]]
    BaseApi.fetch_data(path, options)
  end

end
