defmodule BankMvp.MixProject do
  use Mix.Project

  def project do
    [
      app: :bank_mvp,
      version: "0.1.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {BankMvp, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:swoosh, "~> 0.18"},
      {:logger_file_backend, "~> 0.0.10"}
    ]
  end
end
