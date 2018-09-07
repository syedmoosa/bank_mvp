defmodule BankMvp do
  @moduledoc false

  use Application

  def start(_type, _args) do
    BankMvp.Supervisor.start_link([])
  end
end
