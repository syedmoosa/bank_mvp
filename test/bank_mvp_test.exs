defmodule BankMvpTest do
  use ExUnit.Case
  alias BankMvp.Bank
  doctest BankMvp

  test "registration of user" do
    assert  {:ok, userid} = Bank.register_user("bsyed6@gmail.com", "password", 500)
    assert  {:error, reason} = Bank.register_user("bsyed6@gmail.com", "password", 450)
  end
end
