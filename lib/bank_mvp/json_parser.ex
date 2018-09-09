defmodule BankMvp.JsonParser do
  @moduledoc false
  alias BankMvp.TransactionModel

  def write_to_file(user_id, transactions) do
    File.mkdir_p("./transactions/"<>user_id)
    with {:ok, file} <- File.open("./transactions/"<>user_id<> "/"<>user_id <>".txt", [:append, :utf8]) do
      write(file, transactions)
    else
      _any -> {:error, :unable_to_write_to_file}
    end

  end

  def write(file, []) do
    File.close(file)
    {:ok, :written_to_file}
  end

  def write(file, [head|rest]) do
    %TransactionModel{date: date, description: desc, type: type,
      amount: amount, balance: balance} = head
    date = :erlang.integer_to_binary(date)
    type = :erlang.atom_to_binary(type, :utf8)
    amount = :erlang.float_to_binary(amount, [{:decimals, 2}])
    balance = :erlang.float_to_binary(balance, [{:decimals, 2}])

    obj = <<"{\"date\": ">> <> date <> <<",\"description\":\"">> <> desc <> <<"\", \"
    type\":\"">> <> type <><<"\", \"amount\":">> <> amount <> <<", \"balance\":">> <> balance <> <<"}">>

    IO.inspect(file, obj, binaries: :as_strings)

    write(file, rest)
  end

end
