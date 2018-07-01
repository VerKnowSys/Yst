defmodule Yst do
  @moduledoc "YoungSkilled OST"

  require Logger
  use Supervisor


  def start_link do
    init_amnesia()
    Supervisor.start_link __MODULE__, [], name: __MODULE__
  end


  def setup_log_level do
    # NOTE: Setup logger level per env::
    case Cfg.env() do
      :dev ->
        Cfg.log_level :debug
      _ ->
        Cfg.log_level :info
    end
  end


  def init [] do
    setup_log_level()

    children = [
      worker(Results, []),
      worker(Director, [])
    ]

    supervise children, strategy: :one_for_one
  end


  def init_amnesia do
    Cfg.set_default_mnesia_dir Cfg.project_dir()
    Logger.info "Yst is launching DbApi for Amnesia in dir: #{Cfg.project_dir()}"
    DbApi.init_and_start()
    DbApi.dump_mnesia "current"
  end


  def run, do: main []
  def main, do: main []
  def main _ do
    case Yst.start_link() do
      {:ok, _} ->
        Logger.info "Yst-Supervisor started (env: #{Cfg.env()})"

      {:error, {:already_started, _}} ->
        Logger.info "Yst-Supervisor already started (env: #{Cfg.env()})"

    end
    Results.reset()
    Director.claps()
    Director.results()
  end

end
