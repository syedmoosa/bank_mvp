defmodule BankMvp.Supervisor do
  @moduledoc false

  use Supervisor

  def start_link(arg) do
    Supervisor.start_link(__MODULE__, arg, name: __MODULE__)
  end

  def init(arg) do
    children = [
      BankMvp.UserLocator,
      BankMvp.UserProfileDb,
      {DynamicSupervisor, name: BankMvp.UserSupervisor, strategy: :one_for_one}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end