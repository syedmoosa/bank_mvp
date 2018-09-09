defmodule BankMvp.User do
  @moduledoc false
  use GenServer
  alias BankMvp.TransactionModel, as: Transaction
  alias BankMvp.UserController, as: UC


  def start_link(user_id, deposit) do
    GenServer.start_link(__MODULE__, [user_id, deposit], [])
  end

  def init([user_id, deposit]) do
    timestamp = :calendar.datetime_to_gregorian_seconds(:calendar.universal_time()) - 62167219200 # Epoch Time
    t = %Transaction{date: timestamp, description: "Account created", type: :credit, balance: deposit, amount: deposit }
    {:ok, %{id: user_id, transaction_history: [t]}}
  end

  def handle_call({:credit, amount}, _from, %{id: user_id} = state) do
    timestamp = :calendar.datetime_to_gregorian_seconds(:calendar.universal_time()) - 62167219200
    case UC.deposit(user_id, amount) do
      response = {:ok, new_balance}->
        new_transaction = %Transaction{date: timestamp, description: "deposit",
          type: :credit, balance: new_balance, amount: amount}
        new_state = state |> Map.update(:transaction_history, 0, fn transaction->[new_transaction|transaction]  end)
        {:reply, response, new_state}

      response = {:error, _reason}->
        {:reply, response, state}
    end
  end

  def handle_call({:debit, amount}, _from, %{id: user_id} = state) do
    timestamp = :calendar.datetime_to_gregorian_seconds(:calendar.universal_time()) - 62167219200
    case UC.withdraw(user_id, amount) do
      response = {:ok, new_balance, debit_charge}->
        Process.send_after(self(), :check_minimum_balance, 10*1000)
        new_transaction = %Transaction{date: timestamp, description: "withdraw",
          type: :debit, balance: new_balance + debit_charge, amount: amount}
        dt = %Transaction{date: timestamp, description: "debit charge 5%",
          type: :debit, balance: new_balance, amount: debit_charge}
        new_state = state |> Map.update(:transaction_history, 0, fn transaction->[new_transaction, dt|transaction]  end)
        {:reply, response, new_state}

      {:below_minimum_balance, new_balance, debit_charge}->
        Process.send_after(self(), :check_minimum_balance, 10*1000)
        new_transaction = %Transaction{date: timestamp, description: "deposit",
          type: :credit, balance: new_balance + debit_charge, amount: amount}
        dt = %Transaction{date: timestamp, description: "debit charge 5%",
          type: :debit, balance: new_balance, amount: debit_charge}
        new_state = state |> Map.update(:transaction_history, 0, fn transaction->[new_transaction, dt|transaction]  end)
        {:reply, {:ok, new_balance}, new_state}

      response = {:error, _reason}->
        {:reply, response, state}
    end
  end

  def handle_call(_msg, _from, state) do
    {:reply, :ok, state}
  end

  def handle_cast(_msg, state) do
    {:noreply, state}
  end

  def handle_info(:check_minimum_balance, %{id: user_id} = state) do
    case UC.check_minimum_balance(user_id) do
      {:ok, balance, debit_charge}->
        Process.send_after(self(), :check_minimum_balance, 10*1000)
        timestamp = :calendar.datetime_to_gregorian_seconds(:calendar.universal_time()) - 62167219200
        dt = %Transaction{date: timestamp, description: "Minimum Balance fine 10%",
          type: :debit, balance: balance, amount: debit_charge}
        new_state = state |> Map.update(:transaction_history, 0, fn transaction->[dt|transaction]  end)
        IO.inspect {user_id, balance}
        {:noreply, new_state}
      {:ok, :amount_greater_than_minimum_balance}->
        {:noreply, state}
    end
  end

  def handle_info(_msg, state) do
    {:noreply, state}
  end

end