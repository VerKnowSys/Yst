defmodule Director do
  @moduledoc """
  Director GenServer - entity to process scenarios.
  """

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
  Director "claps" - starts scenario script and fill Results queue
  Works synchronously.
  """
  def claps do
    GenServer.call __MODULE__, :run, (Application.get_env :yst, :scene_timeout)
  end


  @doc """
  Director "results" - renders Results queue
  """
  def results do
    GenServer.call __MODULE__, :result, (Application.get_env :yst, :result_timeout)
  end


  defp process_results do
    Logger.info "-----------------------------------------------------------------------------------------------------------------------------------------------------------------"

    Logger.info "Scenario results:"
    for res <- Results.show do
      case res do

        {:success, scene, message} ->
          name = String.rjust scene.name, 25
          msg = String.rjust message, 61
          request = String.rjust scene.req!, 15
          time_ms = String.rjust "#{scene.actions_ms}ms ⌛", 9
          act = String.rjust "#{IO.ANSI.green}#{scene.act}#{IO.ANSI.default_color}", 2
          garrow = "#{IO.ANSI.cyan} ⇒#{IO.ANSI.default_color}"
          Logger.info "#{IO.ANSI.green}✓#{IO.ANSI.default_color} Act#{garrow} #{act}, Name#{garrow} #{IO.ANSI.green}#{name}#{IO.ANSI.default_color},\t Msg#{garrow} #{IO.ANSI.green}#{msg}#{IO.ANSI.default_color},\tReq#{garrow} #{IO.ANSI.yellow}#{request}#{IO.ANSI.default_color},\tTime#{garrow} #{IO.ANSI.magenta}#{time_ms}#{IO.ANSI.default_color}"

        {:failure, scene, message} ->
          name = String.rjust scene.name, 25
          msg = String.rjust message, 61
          request = String.rjust scene.req!, 15
          time_ms = String.rjust "#{scene.actions_ms}ms ⌛", 9
          act = String.rjust "#{IO.ANSI.red}#{scene.act}#{IO.ANSI.default_color}", 2
          garrow = "#{IO.ANSI.cyan} ⇒#{IO.ANSI.default_color}"
          Logger.error "#{IO.ANSI.red} λ#{IO.ANSI.default_color} Act#{garrow} #{act}, Name#{garrow} #{IO.ANSI.red}#{name}#{IO.ANSI.default_color},\t Msg#{garrow} #{IO.ANSI.red}#{msg}#{IO.ANSI.default_color},\tReq#{garrow} #{IO.ANSI.yellow}#{request}#{IO.ANSI.default_color},\tTime#{garrow} #{IO.ANSI.magenta}#{time_ms}#{IO.ANSI.default_color}"

        res ->
          Logger.warn "Error: Unknown entry: #{inspect res}"
      end
    end
    Logger.info "-----------------------------------------------------------------------------------------------------------------------------------------------------------------"
  end

end
