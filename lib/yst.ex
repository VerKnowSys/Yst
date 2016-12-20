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


  def environment, do: System.get_env "MIX_ENV"


  def init_amnesia do
    Cfg.set_default_mnesia_dir Cfg.project_dir
    Logger.info "Yst is launching DbApi for Amnesia in dir: #{Cfg.project_dir}"
    DbApi.init_and_start
    DbApi.dump_mnesia "current"
  end


  def run, do: main []
  def main, do: main []
  def main _ do
    init_amnesia

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
