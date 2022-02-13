defmodule CryptoBotWeb.VerifyToken do
  use CryptoBotWeb, :controller

  
  def call(conn, _params) do
    conn 
    
  end

  @spec call(Conn.t(), :not_authenticated) :: Conn.t()
  def call(conn, :not_authenticated) do
    conn
    |> put_status(401)
    |> json(%{error: %{code: 401, message: "Not authenticated"}})
  end

end
