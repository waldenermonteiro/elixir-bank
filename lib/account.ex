defmodule Account do
  defstruct user: User, balance: 1000
  @accounts "accounts.txt"

  def register(user) do
    case search_for_email(user.email) do
      nil ->
        binary = [%__MODULE__{user: user}] ++ search_accounts()
        |> :erlang.term_to_binary()
        File.write(@accounts, binary)
      _-> {:error, "Conta ja cadastrada"}
    end

  end
  def search_accounts do
    {:ok, binary} = File.read(@accounts)
    :erlang.binary_to_term(binary)
  end

  def search_for_email(email) do
    Enum.find(search_accounts(), fn account -> account.user.email == email end)
  end

  def transfer(origin, destiny, value) do
    origin = search_for_email(origin.user.email)
    cond do
      validate_balance(origin.balance, value) -> {:error, "Insuficient balance"}

      true ->
        accounts = search_accounts()
        accounts = List.delete(accounts, origin)
        accounts = List.delete(accounts, destiny)

        origin = %Account{origin | balance: origin.balance - value}
        destiny = %Account{destiny | balance: destiny.balance + value}

        accounts = accounts ++ [origin, destiny]

        File.write!(@accounts, :erlang.term_to_binary(accounts))
    end
  end

  def withdraw(account, value)  do
    cond do
      validate_balance(account.balance, value) -> {:error, "Insuficient balance"}
       true  ->
        accounts = search_accounts()
        accounts = List.delete(accounts, account)
        account = %Account{account | balance: account.balance - value}

        accounts = accounts ++ [account]
        File.write!(@accounts, :erlang.term_to_binary(accounts))

        {:ok, account, "Mensagem de email encaminhada"}
    end
  end
  defp validate_balance(balance, value) do
    balance < value
  end
end
