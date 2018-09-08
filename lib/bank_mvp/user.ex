defmodule BankMvp.User do
  @moduledoc false
  


  use GenServer

  def start_link(user_id) do
    GenServer.start_link(__MODULE__, [user_id], [])
  end

  def init([user_id]) do
    {:ok, %{id: user_id}}
  end

  def handle_call(_msg, _from, state) do
    {:reply, :ok, state}
  end

  def handle_cast(_msg, state) do
    {:noreply, state}
  end
end