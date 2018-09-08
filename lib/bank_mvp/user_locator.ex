defmodule BankMvp.UserLocator do
  @moduledoc false
  


  use GenServer

#  Client API
  def lookup(userid) do
    GenServer.call(Locator,{:lookup, userid})
  end



  def start_link(_opts) do
    GenServer.start_link(__MODULE__, :ok, name: Locator)
  end

  def init(_opts) do
    table = :ets.new(:users_location, [:named_table, :protected])
    {:ok, %{locator: table}}
  end

  def handle_call({:lookup, userid}, _from, state) do
    {:reply, {:found, userid}, state}
  end

  def handle_call({:insert, userid, pid}, _from, %{locator: table}= state) do
    response = case :ets.insert_new(table, {userid, pid}) do
      true -> {:ok, userid}
      false -> {:error, "UserID and Pid not added in locator!"}
    end
    {:reply, response, state}
  end

  def handle_call(_msg, _from, state) do
    {:reply, :ok, state}
  end

  def handle_cast(_msg, state) do
    {:noreply, state}
  end





end