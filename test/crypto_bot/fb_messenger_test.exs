defmodule CryptoBot.FbMessengerTest do
  use CryptoBot.DataCase

  describe "Message" do
    alias CryptoBot.FbMessenger

    test "reply_for/1 top:7 should return 7 buttons" do
      response = FbMessenger.reply_for("top:7") |> Jason.decode!
      assert Map.has_key?(response, "attachment")
      elements = response["attachment"]["payload"]["elements"]
      button_count = 0
      buttons = Enum.map(elements, fn element -> 
        length(element["buttons"])
      end)
      assert length(elements) == 3
      assert Enum.sum(buttons) == 7
    end

    test "reply_for/1 price:iotex should return price details" do
      response = FbMessenger.reply_for("price:iotex") |> Jason.decode!
      elements = response["attachment"]["payload"]["elements"]
      element  = elements |> List.first
      button   = element["buttons"] |> List.first
      buttons  = Enum.map(elements, fn element -> 
        length(element["buttons"])
      end)
      assert length(elements) == 1
      assert Enum.sum(buttons) == 1
      assert String.contains?(element["title"], "IoTeX") == true
      assert button["payload"] == "market:iotex"
    end

    test "reply_for/1 price: should return help page" do
      response = FbMessenger.reply_for("price:")
      assert response == CryptoBot.Message.help_text
    end

    test "reply_for/1 invalid input should return help page" do
      response = FbMessenger.reply_for(":6")
      assert response == CryptoBot.Message.help_text
    end

    test "reply_for/1 market input should return help page" do
      response = FbMessenger.reply_for("market:shiba-inu") |> Jason.decode!
      assert String.contains?(response["text"], "Last 14 days") == true
    end

  end


end
