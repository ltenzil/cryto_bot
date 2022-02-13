defmodule CryptoBotWeb.PageController do
  use CryptoBotWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
