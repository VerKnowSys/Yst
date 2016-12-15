defmodule Director do

  use GenServer
  require Logger


  @doc """
  Stat synchronous Director supervisor that will process Scenes-script
  """
  def start_link do
    any = GenServer.start_link __MODULE__, [], name: __MODULE__
    claps
    any
  end


  def handle_call :run, _from, _state do
    pr = process_scenarios
    {:reply, pr, pr}
  end

  def handle_call :result, _from, _state do
    ps = process_results
    {:reply, ps, ps}
  end


  def claps do
    GenServer.call __MODULE__, :run, (Application.get_env :yst, :scene_timeout)
    GenServer.call __MODULE__, :result, (Application.get_env :yst, :result_timeout)
  end

  defp process_scenarios do
    Hound.start_session

    scenes = BasicLoginLogoutScene.script ++ HeadlessScene.script
    scenes |> Scenarios.play

    Hound.end_session
    scenes
  end


  defp process_results do
    Logger.info "Scenario results:"
    for res <- Results.show do
      case res do
        {:passed, msg, where} ->
          Logger.info "Passed: #{msg}\t-=> #{where}"

        {:failed, msg, where} ->
          Logger.error "Failed: #{msg}\t-=> #{where}"
      end
    end
  end

end
