defmodule BankMvp.UserController do
  @moduledoc false
  alias BankMvp.UserModel

  def new() do
    UserModel.new()
  end

  def add_user(table, id, email, password, deposit) do
    value = %UserModel{email: email, password: password, balance: deposit}
    UserModel.insert(id, value)
  end


end
