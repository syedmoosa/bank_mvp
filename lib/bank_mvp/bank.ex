defmodule BankMvp.Bank do
  alias BankMvp.{UserSupervisor, User}
  alias BankMvp.BankValidation, as: BV

  @doc """
  To register the user with email, password and deposit amount.

  Deposit amount should be greater than 500

"""

  @type user_id :: binary()
  @type reason :: :invalid_credentials |
                  :user_not_found |
                  :amount_is_not_deposited |
                  :minimum_deposit_amount_is_500 |
                  :minimum_credit_amount_is_100 |
                  :amount_is_not_credited |
                  :insufficient_balance |
                  :amount_greater_than_balance |
                  :unable_to_get_user_details |
                  :unable_to_send_email |
                  :cant_transfer_to_same_account |
                  :minimum_transfer_amount_is_200

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
    {:error, :minimum_deposit_amount_is_500}
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
      {:error, reason} -> {:error, reason}
    end
  end


  def debit(user_id, password, amount) do
    with {:ok, :valid_credentials} <- validate_user(user_id, password),
         true <- BV.validate_amount(:credit, amount),
         {:ok, pid} <- get_user_location(user_id),
         {:ok, balance} <- debit_amount(pid, amount) do
      {user_id, balance}

    else
      {:error, reason} -> {:error, reason}
    end
  end


  def email_transaction(user_id) do
    import Swoosh.Email
    alias BankMvp.Mailer

    with {:ok, to_user} <- get_user_details(user_id) do

    email = new()
      |> to(to_user)
      |> from({"BankMvp", "bankmvp53@gmail.com"})
      |> subject("Transaction History")
      |> text_body("Hi, Please find attached the statement of your transactions")
      |> attachment("./transactions/"<>user_id<> "/"<>user_id <>".txt")
    Mailer.deliver(email)
    else
      {:error, :unable_to_get_user_details}->
        {:error, :unable_to_send_email}

    end
  end

  def transfer_money(user_id, _password, _amount, user_id) do
    {:error, :cant_transfer_to_same_account}
  end

  def transfer_money(user_id, password, amount, to) do
     with {:ok, :valid_credentials} <- validate_user(user_id, password),
          true <- BV.validate_amount(:transfer, amount),
          {:ok, pid} <- get_user_location(user_id),
          {:ok, to_pid} <- get_user_location(to),
          {:ok, balance} <- transfer_amount(pid, to, to_pid, amount) do
        {user_id, balance}
       else
       {:transfer, false}-> {:error, :minimum_transfer_amount_is_200}
       {:error, reason}-> {:error, reason}
       end
     end


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

  defp debit_amount(pid, amount) do
    GenServer.call(pid, {:debit, amount})
  end

  defp validate_user(user_id, password) do
    GenServer.call(UserProfileDB, {:validate_user, user_id, :crypto.hash(:md5, password)})
  end

  defp get_user_details(user_id) do
    GenServer.call(UserProfileDB, {:get_user_details, user_id})
  end

  defp transfer_amount(pid, to, to_pid, amount) do
    GenServer.call(pid, {:transfer, to, to_pid, amount})
  end

end




