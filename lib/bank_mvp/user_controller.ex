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
      {:ok, %UserModel{password: exist_password} =_value} when exist_password == password ->
        {:ok, :valid_credentials}
      {:ok, _}-> {:error, :invalid_credentials}
      {:error, :not_found}->
        {:error, :user_not_found}
    end
  end

  def deposit(user_id, amount) do
    with {:ok, user} <- UserModel.get_user(:users_profile, user_id),
    {:ok, _old_balance, new_user} <- add(user, amount),
    {:ok, _user_id} <- UserModel.insert(:users_profile, user_id, new_user) do
      {:ok, Map.get(new_user, :balance)}
    else
      {:error, :not_found}-> {:error, :amount_is_not_deposited}
    end

  end

  def withdraw(user_id, amount) do
    with {:ok, user} <- UserModel.get_user(:users_profile, user_id),
         {:ok, _old_balance, new_user, debit_charge} <- subtract(user, amount),
         {:ok, _user_id} <- UserModel.insert(:users_profile, user_id, new_user) do
      case Map.get(new_user, :balance) do
        balance when balance >= 500 -> {:ok, balance, debit_charge}
        balance when balance < 500 -> {:below_minimum_balance, balance, debit_charge}
      end
    else
      {:error, :amount_greater_than_balance = reason}-> {:error, reason}
      {:error, :insufficient_balance = reason}-> {:error, reason}
      {:error, :not_found}-> {:error, :amount_is_not_debited}
    end

  end

  def check_minimum_balance(user_id) do
    with {:ok, user} <- UserModel.get_user(:users_profile, user_id),
         true <- is_below_minimum?(Map.get(user, :balance)),
         {:ok, _old_balance, new_user, debit_charge} <- charge_fine(user),
         {:ok, _user_id} <- UserModel.insert(:users_profile, user_id, new_user) do
      {:ok, Map.get(new_user, :balance), debit_charge}
    else
      false -> {:ok, :amount_greater_than_minimum_balance}
      {:error, :not_found}-> {:error, :unable_to_check_balance}
    end
  end


  def get_user_details(table, user_id) do
    with {:ok, user}<- UserModel.get_user(table, user_id) do
      {:ok, Map.get(user, :email)}
    else
      {:error, :not_found}-> {:error, :unable_to_get_user_details}
    end
  end

  def transfer_money(user_id, amount, to, to_pid) do
    with {:ok, balance, debit_charge} <- withdraw(user_id, amount),
         {:ok, new_balance} <- deposit(to, amount),
         :ok <- inform_transfered_amount(user_id, to_pid, new_balance-amount, new_balance) do
      {:ok, balance, debit_charge}
    else
      {:below_minimum_balance, _balance, _debit_charge} = response-> response
      {:error, :amount_greater_than_balance = reason}  -> {:error, reason}
      {:error, :insufficient_balance = reason}-> {:error, reason}
      {:error, :not_found}-> {:error, :amount_is_not_debited}
    end

  end

#---------------- INTERNAL FUNCTIONS

  defp add(user, amount) do
    {old_balance, new_user} = Map.get_and_update(user, :balance, fn current_balance->
      new_balance = current_balance + amount
      {current_balance, Float.round(new_balance,2)} end)
    {:ok, old_balance, new_user}
  end

  defp subtract(%UserModel{balance: balance}=user, amount) when amount < balance and balance >= 500 do
    debit_charge = 5/100 * 500
    {old_balance, new_user} = Map.get_and_update(user, :balance, fn current_balance->
                    new_balance = (current_balance - amount) - debit_charge
                    {current_balance, Float.round(new_balance,2)} end)
    {:ok, old_balance, new_user, debit_charge}
  end

  defp subtract(%UserModel{balance: balance}, _amount) when balance < 500 do
    {:error, :insufficient_balance}
  end

  defp subtract(_, _) do
    {:error, :amount_greater_than_balance}
  end

  defp is_below_minimum?(balance) when balance >= 500, do: false
  defp is_below_minimum?(balance) when balance < 500, do: true

  defp charge_fine(user) do
    debit_charge = 10/100 * 500
    {old_balance, new_user} = Map.get_and_update(user, :balance, fn current_balance->
      new_balance = current_balance - debit_charge
      {current_balance, Float.round(new_balance,2)} end)
    {:ok, old_balance, new_user, debit_charge}
  end

  defp inform_transfered_amount(from, to, amount, new_balance) do
    GenServer.cast(to, {:transfered_amount, from, amount, new_balance})
    :ok
  end

end
