defmodule BankMvp.User do
  @moduledoc false
  use GenServer
  alias BankMvp.TransactionModel, as: Transaction
  alias BankMvp.UserController, as: UC


  def start_link(user_id, deposit) do
    GenServer.start_link(__MODULE__, [user_id, deposit], [])
  end

  def init([user_id, deposit]) do
    timestamp = :calendar.datetime_to_gregorian_seconds(:calendar.universal_time())
    t = %Transaction{date: timestamp, description: "Account created", type: :credit, balance: deposit }
    {:ok, %{id: user_id, transaction_history: [t]}}
  end

  def handle_call({:credit, amount}, _from, %{id: user_id} = state) do
    timestamp = :calendar.datetime_to_gregorian_seconds(:calendar.universal_time())
    case UC.deposit(user_id, amount) do
      response = {:ok, new_balance}->
        new_transaction = %Transaction{date: timestamp, description: "deposit", type: :credit, balance: new_balance}
        new_state = state |> Map.update(:transaction_history, 0, fn transaction->[new_transaction|transaction]  end)
        {:reply, response, new_state}

      response = {:error, reason}->
        {:reply, response, state}
    end
  end

  def handle_call(_msg, _from, state) do
    {:reply, :ok, state}
  end

  def handle_cast(_msg, state) do
    {:noreply, state}
  end
end