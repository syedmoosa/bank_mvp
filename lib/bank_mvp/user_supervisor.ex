defmodule UserSupervisor do
  @moduledoc false
  


  use Supervisor

  def start_link(arg) do
    Supervisor.start_link(__MODULE__, arg)
  end

  def init(arg) do
    children = []

    supervise(children, strategy: :one_for_one)
  end
end