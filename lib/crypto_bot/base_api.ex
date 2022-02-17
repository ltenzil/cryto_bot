defmodule CryptoBot.BaseApi do

  @headers  [{"Content-type", "application/json"}]

  @type resp :: map()
  @type body :: map()
  @type path :: String.t
  @type options :: list()
  @type success_map :: {:ok, map()}
  @type error_map :: {:error, msg: String.t}

  @spec fetch_data(path, options) :: success_map | error_map
  def fetch_data(path, options \\ []) do
    HTTPoison.get(path, @headers, options)
    |> handle_reponse
  end

  @spec post_data(path, body) :: success_map | error_map
  def post_data(path, body) do
    path
    |> HTTPoison.post(Jason.encode!(body), @headers)
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
      {:ok, %HTTPoison.Response{status_code: 400, body: body}} ->
        response = Jason.decode!(body)
        IO.inspect(response)
        {:ok, msg: response["error"]["message"] }
    end
  end

end
