defmodule BankMvp.UserProfileDb do
  @moduledoc false


  use GenServer
  alias BankMvp.{UserController}

  def start_link(state) do
    GenServer.start_link(__MODULE__, state, name: UserProfileDB)
  end

  def init(_opts) do
    table = UserController.new()
    {:ok, %{users: table}}
  end

  def handle_call({:add_user, id, email, password, deposit}, _from, %{users: table}= state) do
    response =  UserController.add_user(table, id, email, password, deposit)
    {:reply, response, state}
  end

  def handle_call({:validate_user, user_id, password}, _from, %{users: table}= state) do
    response = UserController.validate_user(table, user_id, password)
    {:reply, response, state}
  end

  def handle_call({:get_user_details, user_id}, _from, %{users: table}= state) do
    response = UserController.get_user_details(table, user_id)
    {:reply, response, state}
  end

  def handle_call({:close_account, user_id}, _from, %{users: table}= state) do
    response = UserController.close_account(table, user_id)
    {:reply, response, state}
  end

  def handle_call(_msg, _from, state) do
    {:reply, :ok, state}
  end

  def handle_cast(_msg, state) do
    {:noreply, state}
  end
end