defmodule Director do
  @moduledoc """
  Director GenServer - entity to process scenarios.
  """

  use GenServer

  require Logger
  alias IO.ANSI
  import ANSI


  @doc """
  Stat synchronous Director supervisor that will process Scenes-script
  """
  def start_link do
    GenServer.start_link __MODULE__, [], name: __MODULE__
  end


  def handle_call :run, _from, _state do
    Hound.start_session()
    pr = process_scenarios()
    Hound.end_session()
    {:reply, pr, pr}
  end

  def handle_call :result, _from, _state do
    ps = process_results()
    {:reply, ps, ps}
  end


  defp process_scenarios do
    scscripts = ScenesList.scripts()
    scscripts |> Scenarios.play()
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
    for res <- Results.show() do
      case res do

        {:success, scene, message} ->
          name = String.rjust scene.name, 25
          msg = String.rjust message, 61
          request = String.rjust scene.req!, 15
          time_ms = String.rjust "#{scene.actions_ms}ms ⌛", 9
          act = String.rjust "#{green}#{scene.act}#{default_color}", 2
          garrow = "#{cyan} ⇒#{default_color}"
          Logger.info "#{green}✓#{default_color} Act#{garrow} #{act}, Name#{garrow} #{green}#{name}#{default_color},\t Msg#{garrow} #{green}#{msg}#{default_color},\tReq#{garrow} #{yellow}#{request}#{default_color},\tTime#{garrow} #{magenta}#{time_ms}#{default_color}"

        {:failure, scene, message} ->
          name = String.rjust scene.name, 25
          msg = String.rjust message, 61
          request = String.rjust scene.req!, 15
          time_ms = String.rjust "#{scene.actions_ms}ms ⌛", 9
          act = String.rjust "#{red}#{scene.act}#{default_color}", 2
          garrow = "#{cyan} ⇒#{default_color}"
          Logger.error "#{red} λ#{default_color} Act#{garrow} #{act}, Name#{garrow} #{red}#{name}#{default_color},\t Msg#{garrow} #{red}#{msg}#{default_color},\tReq#{garrow} #{yellow}#{request}#{default_color},\tTime#{garrow} #{magenta}#{time_ms}#{default_color}"

        res ->
          Logger.warn "Error: Unknown entry: #{inspect res}"
      end
    end
    Logger.info "-----------------------------------------------------------------------------------------------------------------------------------------------------------------"
  end

end
