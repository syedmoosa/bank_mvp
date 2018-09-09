defmodule BankMvp.BankValidation do

  def validate_amount(:credit, amount) when amount >= 100, do: true

  def validate_amount(:transfer, amount) when amount >= 200, do: true

  def validate_amount(:credit, _), do: {:credit, false}

  def validate_amount(:transfer, _), do: {:transfer, false}


end
