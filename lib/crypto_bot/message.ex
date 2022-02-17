defmodule CryptoBot.Message do

  def text_msg(msg), do: Jason.encode!(%{text: msg})
  def attachment_msg(attachment), do: Jason.encode!(attachment)
  def quick_msg(msg, title) do
    %{
      text: title,
      quick_replies: msg
    } |> Jason.encode!    
  end

  def analyse_input(query), do: String.split(query, ":")

  @spec default_menu :: list()
  def default_menu do
    menu = []
    menu = menu ++ [%{"name" => "top:10", "payload" => "top:10" }]
    menu = menu ++ [%{"name" => "price:iotex", "payload" => "price:iotex" }]
    menu = menu ++ [%{"name" => "market:ripple", "payload" => "market:ripple" }]
  end

  def help_text do
    title = "Our features are restricted to few keywords:"
    menus = Enum.map(default_menu, &(buttons(&1))) 
    elements = [element_format(menus, title)]
    |> attachment_format
  end

  @spec attachment_format(list()) :: map()
  def attachment_format(elements) do
    %{ attachment: 
      %{
        type: "template",
        payload: %{
          template_type: "generic",
          elements: elements
        }
      }
    } |> attachment_msg
  end

  @spec element_format(list(), String.t) :: map()
  def element_format(buttons, title \\ "Top Coins:") do
    %{ title: title, buttons: buttons }
  end
  
  @spec element_format(list(), String.t, String.t) :: map()
  def element_format(buttons, title, subtitle) do
    %{ title: title, subtitle: subtitle, buttons: buttons }
  end

  @spec price_button(map()) :: map()
  def price_button(coin) do
    %{      
      type: "postback",
      title: coin["name"],
      payload: "price:#{String.downcase(coin["id"])}"
    }
  end

  @spec buttons(map()) :: map()
  def buttons(coin) do
    %{      
      type: "postback",
      title: coin["name"],
      payload: coin["payload"]
    }
  end

  def quick_buttons(coin) do
    # quick_msg(coin_batches, "Top coins:")
    %{
      content_type: "text",
      title: coin["name"],
      payload: "price:#{String.downcase(coin["id"])}"
    }
  end

end
