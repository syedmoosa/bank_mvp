
defmodule BankMvp.Mailer do
  @moduledoc false
  use Swoosh.Mailer, otp_app: :bank_mvp,
  adapter: Swoosh.Adapters.Sendgrid,
    api_key: "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"

end