defmodule Yst do
  @moduledoc "YoungSkilled OST"

  use Supervisor
  require Logger


  def start_link do
    Supervisor.start_link __MODULE__, [], name: __MODULE__
  end


  def init [] do
    children = [
      worker(Results, []),
      worker(Director, [])
    ]

    supervise children, strategy: :one_for_one
  end


  defp environment do
    case System.get_env "MIX_ENV" do
      "" -> "dev"
      any -> any
    end
  end


  def run, do: main []
  def main, do: main []
  def main _ do
    case Yst.start_link do
      {:ok, _} ->
        Logger.info "Yst-Supervisor started (env: #{environment})"

      {:error, {:already_started, _}} ->
        Logger.debug "Yst-Supervisor already started (env: #{environment})"
    end
    Results.reset
    Director.claps
    Director.results
  end

end
