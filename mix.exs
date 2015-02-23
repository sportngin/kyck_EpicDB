defmodule EpicDb.Mixfile do
  use Mix.Project

  def project do
    [app: :epic_db,
     version: "0.0.1",
     elixir: "~> 1.0",
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [
      mod: {EpicDb, []},
      applications: [:logger, :amqp, :poolboy, :jsxn, :httpoison, :ex_statsd]
    ]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type `mix help deps` for more examples and options
  defp deps do
    [
      {:amqp, "~> 0.1.0"},
      {:jsx,  "~> 2.0"},
      {:jsxn, "0.2.1"},
      {:httpoison, "~> 0.5"},
      {:poolboy, "~> 1.4.0"},
      {:exrm, "~> 0.15.0"},
      {:ex_statsd, ">= 0.5.0"}
    ]
  end
end
