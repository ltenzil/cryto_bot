defmodule CryptoBot.CoinGeckoApi do

  @endpoint "https://api.coingecko.com/api/v3/"
  @headers  [{"content-type", "application/json"}]

  @type resp :: map()
  @type coin :: String.t
  @type path :: String.t
  @type currency :: String.t
  @type interval :: integer
  @type options :: list()
  @type success_map :: {:ok, map()}
  @type error_map :: {:error, msg: String.t}

  @spec list_coins :: success_map | error_map
  def list_coins do
    fetch_data('coins/list')
  end

  @spec info(coin) :: success_map | error_map
  def info(coin) do
    path    = "coins/#{coin}"
    options = [params: [localization: false, tickers: false, 
                        community_data: false,
                        developer_data: false, sparkline: false]]
    fetch_data(path, options)
  end

  
  @spec top_five(currency) :: success_map | error_map
  def top_five(currency \\ "usd") do
    path    = "coins/markets"
    options = [params: [vs_currency: currency, order: "market_cap_desc", 
                        per_page: 5, page: 1]]
    fetch_data(path, options)
  end

  
  @spec market_data(coin, currency, interval) :: success_map | error_map
  def market_data(coin, currency \\ "usd", interval \\ 14) do
    path    = "coins/#{coin}/market_chart"
    options = [params: [vs_currency: currency, days: interval]]
    fetch_data(path, options)
  end

  
  @spec fetch_data(path, options) :: success_map | error_map
  defp fetch_data(path, options \\ []) do
    url = @endpoint <> path
    |> HTTPoison.get(@headers, options)
    |> handle_reponse
  end
  
  @spec handle_reponse(resp) :: success_map | error_map
  defp handle_reponse(resp) do
    case resp do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, Jason.decode!(body) }
      {:ok, %HTTPoison.Response{status_code: 404}} ->
        {:error, msg: 'Coin not found, Please check the value'}
      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, msg: reason}      
    end
  end

end
