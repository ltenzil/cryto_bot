defmodule CryptoBot.CoinGeckoApi do
  
  alias CryptoBot.BaseApi

  @endpoint "https://api.coingecko.com/api/v3/"

  @type coin :: String.t
  @type path :: String.t
  @type currency :: String.t
  @type interval :: integer
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

  
  @spec top_five(currency) :: success_map | error_map
  def top_five(currency \\ "usd") do
    path    = @endpoint <> "coins/markets"
    options = [params: [vs_currency: currency, order: "market_cap_desc", 
                        per_page: 5, page: 1]]
    BaseApi.fetch_data(path, options)
  end

  
  @spec market_data(coin, currency, interval) :: success_map | error_map
  def market_data(coin, currency \\ "usd", interval \\ 14) do
    path    = @endpoint <> "coins/#{coin}/market_chart"
    options = [params: [vs_currency: currency, days: interval]]
    BaseApi.fetch_data(path, options)
  end

end
