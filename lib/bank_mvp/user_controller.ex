defmodule BankMvp.UserController do
  @moduledoc false
  alias BankMvp.UserModel

  def new() do
    UserModel.new()
  end

  def add_user(table, id, email, password, deposit) do
    value = %UserModel{email: email, password: password, balance: deposit}
    UserModel.insert(table, id, value)
  end

  def validate_user(table, user_id, password) do
    case UserModel.get_user(table, user_id) do
      {:ok, %UserModel{password: exist_password} =value} when exist_password == password ->
        {:ok, :valid_credentials}
      {:ok, _}-> {:error, :invalid_credentials}
      {:error, :not_found}->
        {:error, :user_not_found}
    end
  end

  def deposit(user_id, amount) do
    with {:ok, user} <- UserModel.get_user(:users_profile, user_id),
    {_old_balance, new_user} <- add(user, amount),
    {:ok, user_id} <- UserModel.insert(:users_profile, user_id, new_user) do
      {:ok, Map.get(new_user, :balance)}
    else
      {:error, :not_found}-> {:error, :amount_is_not_deposited}
    end

  end

  defp add(user, amount) do
    Map.get_and_update(user, :balance, fn current_balance->
      new_balance = current_balance + amount
      {current_balance, new_balance} end)
  end

end
