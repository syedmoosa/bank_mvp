defmodule BankMvpTest do
  use ExUnit.Case
  alias BankMvp.Bank
  doctest BankMvp

  setup do
    password = "password"
    {:ok, user_id} = Bank.register_user("bankmvp53@gmail.com", password, 500)
    {:ok, user_id2} = Bank.register_user("bsyed6@gmail.com", password, 500)
    {:ok, [user_id: user_id, user_id2: user_id2, password: password]}
  end


  test "registration of user" do
    assert  {:ok, userid} = Bank.register_user("bsyed6@gmail.com", "password", 500)
    assert  {:error, reason} = Bank.register_user("bsyed6@gmail.com", "password", 450)
  end

  test "credit amount", state do
    user_id = state[:user_id]
    assert {user_id, 1.5e3} = Bank.credit(user_id, state[:password], 1000)
    assert {:error, :minimum_credit_amount_is_100} = Bank.credit(user_id, state[:password], 50)
    assert {:error, :invalid_credentials} = Bank.credit(user_id, "pwdsdsds", 50)
  end

  test "debit amount", state do
    user_id = state[:user_id]
    assert {user_id, 375.0} = Bank.debit(user_id, state[:password], 100)
    assert {:error, :insufficient_balance} = Bank.debit(user_id, state[:password], 100)
  end

  test "email transaction", state do
    user_id = state[:user_id]
    :timer.sleep(2000)
    assert {:ok, id} = Bank.email_transaction(user_id)
  end

  test "transfer money", state do
    user_id = state[:user_id]
    user_id2 = state[:user_id2]
    password = state[:password]
    assert {user_id, 1.5e3} = Bank.credit(user_id, password, 1000)
    assert {user_id, 1125.0} = Bank.transfer_money(user_id, password, 350, user_id2)
    assert {:error, :cant_transfer_to_same_account} = Bank.transfer_money(user_id, password, 350, user_id)
  end


end
