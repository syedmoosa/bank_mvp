defmodule BankMvp.UserModel do
  @moduledoc false
  alias __MODULE__

  defstruct [:email, :password, :balance]

  def new() do
    :ets.new(:users_profile, [:named_table, :public, {:read_concurrency, true}])
  end

  def insert(table, id, value) do
    case :ets.insert(table, {id, value}) do
      true -> {:ok, id}
      _any -> {:error, "User registration failed!"}
    end
  end

  def get_user(table, user_id) do
    case :ets.lookup(table, user_id) do
      [{user_id, value}]-> {:ok, value}
      []-> {:error, :not_found}
    end
  end

  def deposit_amount(user_id, amount) do

  end


end
