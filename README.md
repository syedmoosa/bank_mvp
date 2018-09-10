# bank_mvp
A Sample Banking application in Elixir

### Register User
To register a user account, the following function needs to be called with email, password and the deposit amount. you will be getting an unique id which is your user id. you need to have this user id to do all other operations

```
iex(1)> BankMvp.Bank.register_user("bankmvp53@gmail.com", "password", 500)
{:ok, "4923263703768902"}

iex(2)> BankMvp.Bank.register_user("bsyed6@gmail.com", "password", 450)
{:error, :minimum_deposit_amount_is_500}

```
### To Deposit money into your account
To deposit money into your account, the following function needs to be called with user id, password and amount needs to be deposited. 

you will get your user id and new balance in your account as a response

```
iex(3)> BankMvp.Bank.credit("4923263703768902", "password", 1250)
{"4923263703768902", 1750}

iex(4)> BankMvp.Bank.credit("4923263703768902", "password", 50)
{:error, :minimum_credit_amount_is_100}

```

### To withdraw money from your account
To withdraw money from your account, the following function needs to be called with user id, password and amount needs to be withdraw.

you will get your user id and new balance in your account as a response. you will be charged 5% of minimum balance for every debit

```
iex(4)> BankMvp.Bank.debit("4923263703768902", "password", 500)
{"4923263703768902", 1225}

iex(5)> BankMvp.Bank.debit("4923263703768902", "password", 1500)
{:error, :amount_greater_than_balance}

```
### To email the transaction
To email the transaction history, the following function needs to be called with user id.
Swoosh library is added as deps, in order to send email to the user

```
iex(6)> BankMvp.Bank.email_transaction("4923263703768902")
{:ok, %{id: xxxxxxxxx}}

```
### To transfer money to another user account
To transfer money to another user account, the following function needs to be called with user id, password, amount and the receipient user id

```
iex(7)> BankMvp.Bank.register_user("dummy@gmail.com", "password", 500)   
{:ok, "4276563703768910"}

iex(8)> BankMvp.Bank.transfer_money("4923263703768902", "password", 225, "4276563703768910")
{"4276563703768910", 725.0}
{"4923263703768902", 975.0}

iex(9)> BankMvp.Bank.transfer_money("4923263703768902", "password", 350, "4923263703768902") 
{:errror, :cant_transfer_to_same_account}

iex(10)> BankMvp.Bank.transfer_money("4923263703768902", "password", 150, "4276563703768910")
{:error, :minimum_transfer_amount_is_200}

```

### To close the account
To close the account, the following function needs to be called with user id and password

```
iex(4)> BankMvp.Bank.close_account("4923263703768902", "password")
{:ok, :account_closed}

```

For every hour, you will get the transaction history in your email. If you have not maintained your minimum balance, then for every hour 10% of minimum balance will be charged from your account.

