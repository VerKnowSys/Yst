defmodule Yst.Mixfile do
  use Mix.Project

  def project do
    [
      app: :yst,
      version: "0.2.0",
      elixir: "~> 1.3",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      deps: deps(),
      escript: escript,
    ]
  end

  def escript do
    [
      main_module: Yst,
      embed_elixir: true,
      language: :elixir,
      force: false,
      emu_args: []
    ]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger, :hound, :credo, :remix]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:hound, "~> 1.0"},
      {:credo, "~> 0.5", only: [:dev, :test]},
      {:remix, "~> 0.0.1", only: [:dev, :test]},
    ]
  end
end
