defmodule Yst do
  @moduledoc "YoungSkilled OST"

  use Supervisor
  require Logger


  def start_link do
    Supervisor.start_link __MODULE__, [], name: __MODULE__
  end


  def init [] do
    case Application.start :hound do
      :ok ->
        Logger.info "Hounds unleashed."

      {:error, cause} ->
        case cause do
          {:already_started, :hound} ->
            Logger.info "Hounds already unleased."

          {reason, :hound} ->
            Logger.error "Hounds were lost. Cause: #{inspect reason}"
        end
    end

    children = [
      worker(Results, []),
      worker(Director, [])
    ]

    supervise(children, strategy: :one_for_one)
  end




  def run, do: main []
  def main, do: main []
  def main _ do
    # Start supervisor. Director supervisor will start it's work synchronously
    case Yst.start_link do
      {:ok, _} ->
        Logger.info "Yst-Supervisor started. Claps!"
        Director.claps
      {:error, {:already_started, _}} ->
        Director.claps
    end
  end

end
