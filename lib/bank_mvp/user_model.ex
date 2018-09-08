defmodule BankMvp.UserModel do
  @moduledoc false
  alias __MODULE__

  defstruct [:email, :password, :balance]

  def new() do
    :ets.new(:users_profile, [:named_table, :protected, {:read_concurrency, true}])
  end

  def insert(id, value) do
    case :ets.insert(:users_profile, {id, value}) do
      true -> {:ok, id}
      _any -> {:error, "User registration failed!"}
    end
  end



end
