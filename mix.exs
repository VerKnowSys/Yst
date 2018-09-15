defmodule Yst.Mixfile do
  use Mix.Project

  def project do
    [
      app: :yst,
      version: "0.7.0",
      elixir: "~> 1.7",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      escript: escript(),
      # Docs
      name: "YSt",
      source_url: "https://github.com/VerKnowSys/yst",
      docs: [
        main: "Integration test automator",
        extras: ["README.md"]
      ]
    ]
  end

  def escript do
    [
      main_module: Yst,
      embed_elixir: true,
      language: :elixir,
      force: true,
      emu_args: []
    ]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    common = [:logger, :uuid, :hound, :maru, :amnesia, :idna, :mimerl, :certifi, :metrics, :hackney, :ssl_verify_fun, :cowboy, :exquisite]

    prod = common ++ [:ex_doc]
    dev = common ++ [:remix, :ex_doc, :dialyxir, :credo, :ranch]
    test = common

    apps = case Mix.env() do
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
      {:hound, "~> 1.0", override: true},
      {:credo, "~> 0.9"},
      {:remix, "~> 0.0.2"},
      {:ex_doc, "~> 0.14"},
      {:uuid, "~> 1.1"},
      {:dialyxir, "~> 0.5"},
      {:maru, "~> 0.13"},
      {:amnesia, github: "meh/amnesia", branch: "master", override: true},
      {:exquisite, github: "meh/exquisite", branch: "master", override: true},
      {:ranch, "~> 1.5"},
      {:cowboy, "~> 2.4"}
    ]
  end
end
