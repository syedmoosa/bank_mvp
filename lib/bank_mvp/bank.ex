defmodule BankMvp.Bank do
  alias BankMvp.{UserSupervisor, User}

  @doc """
  To register the user with email, password and deposit amount.

  Deposit amount should be greater than 500

"""

  @type user_id :: binary()
  @type reason :: list()

  @spec register_user(email:: string, password::string, deposit::integer) ::
          {:ok, user_id}| {:error, reason}
  def register_user(email, password, deposit) when deposit >= 500 do
    with {:ok, user_id} <- create_user_id(),
         {:ok, pid} <- create_child(user_id),
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

  defp create_child(user_id) do
    child_spec = %{id: user_id, start: {User, :start_link, [user_id]}, type: :worker}
    DynamicSupervisor.start_child(UserSupervisor, child_spec)
  end

  defp add_user_location(user_id, pid) do
    GenServer.call(Locator, {:insert, user_id, pid})
  end


end
