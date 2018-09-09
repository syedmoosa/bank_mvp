defmodule BankMvp.Bank do
  alias BankMvp.{UserSupervisor, User}
  alias BankMvp.BankValidation, as: BV

  @doc """
  To register the user with email, password and deposit amount.

  Deposit amount should be greater than 500

"""

  @type user_id :: binary()
  @type reason :: :invalid_credentials |
          :minimum_credit_amount_is_100 |
          :amount_is_not_credited

  @spec register_user(email:: String.t(), password:: String.t(), deposit::integer) ::
          {:ok, user_id}| {:error, reason}
  def register_user(email, password, deposit) when deposit >= 500 do
    with {:ok, user_id} <- create_user_id(),
         {:ok, pid} <- create_child(user_id, deposit),
         {:ok, user_id} <- add_user(user_id, email, password, deposit),
         {:ok, user_id} <- add_user_location(user_id, pid) do
      {:ok, user_id}
    else
      {:error, reason}-> {:error, reason}
    end
  end

  def register_user(_, _, _)do
    {:error, "minimum deposit amount is 500"}
  end

  def credit(user_id, password, amount) do
    with {:ok, :valid_credentials} <- validate_user(user_id, password),
         true <- BV.validate_amount(:credit, amount),
         {:ok, pid} <- get_user_location(user_id),
         {:ok, balance} <- credit_amount(pid, amount) do
            {user_id, balance}

    else
      {:credit, false}-> {:error, :minimum_credit_amount_is_100}
      {:error, :invalid_credentials}-> {:error, :invalid_credentials}
      {:error, reason} -> {:error, :amount_is_not_credited}
    end
  end


#  def debit(_user_id, _password, _amount) do
#
#  end
#
#  def transaction(_user_id) do
#
#  end







#   INTERNAL FUNCTIONS
  defp create_user_id() do
    gregorian_seconds = :calendar.datetime_to_gregorian_seconds(:calendar.universal_time())
    time = :erlang.integer_to_binary(gregorian_seconds)
    random = :crypto.rand_uniform(10000, 99999)
    number = :erlang.integer_to_binary(random)
    {:ok, <<number::binary, time::binary>>}
  end

  defp add_user(id, email, password, deposit) do
    GenServer.call(UserProfileDB, {:add_user, id, email, :crypto.hash(:md5, password), deposit})
  end

  defp create_child(user_id, deposit) do
    child_spec = %{id: user_id, start: {User, :start_link, [user_id, deposit]}, type: :worker}
    DynamicSupervisor.start_child(UserSupervisor, child_spec)
  end

  defp add_user_location(user_id, pid) do
    GenServer.call(Locator, {:insert, user_id, pid})
  end

  defp get_user_location(user_id) do
    GenServer.call(Locator, {:lookup, user_id})
  end

  defp credit_amount(pid, amount) do
    GenServer.call(pid, {:credit, amount})
  end

  defp validate_user(user_id, password) do
    GenServer.call(UserProfileDB, {:validate_user, user_id, :crypto.hash(:md5, password)})
  end

end
