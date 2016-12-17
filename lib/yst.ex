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




  def run, do: main []
  def main, do: main []
  def main _ do
    # Start supervisor. Director supervisor will start it's work synchronously
    case Yst.start_link do
      {:ok, _} ->
        Logger.info "Yst-Supervisor started. Claps!"
      {:error, {:already_started, _}} ->
    end
    Results.reset
    Director.claps
    Director.results
  end

end
