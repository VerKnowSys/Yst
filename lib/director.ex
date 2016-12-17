defmodule Director do

  use GenServer
  require Logger


  @doc """
  Stat synchronous Director supervisor that will process Scenes-script
  """
  def start_link do
    GenServer.start_link __MODULE__, [], name: __MODULE__
  end


  def handle_call :run, _from, _state do
    pr = process_scenarios
    {:reply, pr, pr}
  end

  def handle_call :result, _from, _state do
    ps = process_results
    {:reply, ps, ps}
  end


  defp process_scenarios do
    Hound.start_session

    scscripts = ScenesList.scripts
    scscripts |> Scenarios.play

    Hound.end_session
    scscripts
  end


  @doc """
  Director "claps" - starts scenario script and reports results.
  Works synchronously.
  """
  def claps do
    GenServer.call __MODULE__, :run, (Application.get_env :yst, :scene_timeout)
    GenServer.call __MODULE__, :result, (Application.get_env :yst, :result_timeout)
  end


  defp process_results do
    Logger.info "Scenario results:"
    for res <- Results.show do
      case res do
        {:uuid, uuid} ->
          Logger.debug "Scene id:\t#{uuid}"

        {:success, msg} ->
          Logger.info "Success:\t#{msg}"

        {:failure, msg} ->
          Logger.error "Failure:\t#{msg}"

        res ->
          Logger.warn "Unknown result: #{inspect res}"
      end
    end
  end

end
