defmodule Yst.Mixfile do
  use Mix.Project

  def project do
    [
      app: :yst,
      version: "0.4.3",
      elixir: "~> 1.3",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      deps: deps(),
      escript: escript,
      # Docs
      name: "YSt",
      source_url: "https://github.com/centrahq/yst",
      docs: [
        main: "YS integration test environment",
        extras: ["README.md"]
      ]
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
    common = [:uuid, :hound, :logger]

    prod = common ++ [:ex_doc]
    dev = common ++ [:credo, :remix, :ex_doc, :dialyxir]
    test = common

    apps = case Mix.env do
      :prod -> prod
      :test -> test
      _     -> dev
    end

    [applications: apps]
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
      {:credo, "~> 0.5"},
      {:remix, "~> 0.0.1"},
      {:ex_doc, "~> 0.14"},
      {:uuid, "~> 1.1"},
      {:dialyxir, "~> 0.4"},
    ]
  end
end
