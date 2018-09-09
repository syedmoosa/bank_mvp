defmodule BankMvpTest do
  use ExUnit.Case
  alias BankMvp.Bank
  doctest BankMvp

  setup do
    password = "password"
    {:ok, user_id} = Bank.register_user("dummy@gmail.com", password, 500)
    {:ok, [user_id: user_id, password: password]}
  end


  test "registration of user" do
    assert  {:ok, userid} = Bank.register_user("bsyed6@gmail.com", "password", 500)
    assert  {:error, reason} = Bank.register_user("bsyed6@gmail.com", "password", 450)
  end

  test "credit amount", state do
    user_id = state[:user_id]
    assert {user_id, 1500} = Bank.credit(user_id, state[:password], 1000)
    assert {:error, :minimum_credit_amount_is_100} = Bank.credit(user_id, state[:password], 50)
    assert {:error, :invalid_credentials} = Bank.credit(user_id, "pwdsdsds", 50)
  end

  test "debit amount", state do
    user_id = state[:user_id]
    assert {user_id, 375.0} = Bank.debit(user_id, state[:password], 100)
    assert {:error, :insufficient_balance} = Bank.debit(user_id, state[:password], 100)
  end


end
