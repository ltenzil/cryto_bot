defmodule CryptoBot.MessageTest do
  use CryptoBot.DataCase

  describe "Message" do
    alias CryptoBot.Message

    test "text_msg return message format" do
      text_message = Message.text_msg("New message")
      assert Jason.decode!(text_message)["text"] == "New message"
    end

    test "analyse_input should return type and term" do
      [type, term] = Message.analyse_input("price:iotex")
      assert type == "price"
      assert term == "iotex"
    end

    test "default_menu should have 3 items" do
      menus = Message.default_menu
      assert length(menus) == 3
    end

    test "help_text return message format" do
      help = Jason.decode!(Message.help_text)
      elements = help["attachment"]["payload"]["elements"]
      element  = elements |> List.first
      assert is_list(elements) == true
      assert Map.has_key?(help, "attachment") == true
      assert element["title"] == "Our features are restricted to few keywords:"
    end

    test "elements should have title and buttons format" do
      help = Jason.decode!(Message.help_text)
      elements = help["attachment"]["payload"]["elements"]
      assert is_list(elements) == true
      element  = List.first(elements)
      assert Map.has_key?(element, "title") == true
      assert Map.has_key?(element, "buttons") == true
      assert is_list(element["buttons"]) == true
    end

    test "price_button should have title, payload, type" do
      help = Jason.decode!(Message.help_text)
      elements = help["attachment"]["payload"]["elements"]
      element  = elements |> List.first
      button   = element["buttons"] |> List.first
      assert Map.has_key?(button, "title") == true
      assert Map.has_key?(button, "type") == true
      assert Map.has_key?(button, "payload") == true
    end
  end

end
