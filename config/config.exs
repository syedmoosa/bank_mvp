# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :bank_mvp, BankMailer.Mailer,
       adapter: Swoosh.Adapters.SMTP,
       api_key: "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",
       relay: "smtp.sendgrid.net",
       username: "bankmvp53@gmail.com",
       password: "bank_mvp01",
#       ssl: false,
       tls: :always,
       dkim: [s: "default", d: "smtp.sendgrid.net"],
       retries: 2,
       no_mx_lookups: false
#       port: 25587



config :logger, :console,
       format: "\n$time $metadata[$level] $levelpad$message\n",
       metadata: [:user_id]

# This configuration is loaded before any dependency and is restricted
# to this project. If another project depends on this project, this
# file won't be loaded nor affect the parent project. For this reason,
# if you want to provide default values for your application for
# 3rd-party users, it should be done in your "mix.exs" file.

# You can configure your application as:
#
#     config :bank_mvp, key: :value
#
# and access this configuration in your application as:
#
#     Application.get_env(:bank_mvp, :key)
#
# You can also configure a 3rd-party app:
#
#     config :logger, level: :info
#

# It is also possible to import configuration files, relative to this
# directory. For example, you can emulate configuration per environment
# by uncommenting the line below and defining dev.exs, test.exs and such.
# Configuration from the imported file will override the ones defined
# here (which is why it is important to import them last).
#
#     import_config "#{Mix.env()}.exs"
