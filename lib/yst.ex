defmodule Yst do
  @moduledoc "YoungSkilled OST"

  require Logger


  def main, do: main []
  def main _ do
    run
  end


  def run do
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

    case Results.start_link do
      {:ok, pid} ->
        Logger.info "Results queue started (#{inspect pid})"

      {:error, {:already_started, pid}} ->
        Logger.debug "Results queue already started with pid: #{inspect pid}"

      {:error, er} ->
        Logger.error "Error happened: #{inspect er}"
    end


    Hound.start_session

    scenes = BasicLoginLogoutScene.script ++ HeadlessScene.script
    scenes |> Scenarios.play

    Logger.info "Scenario results:"
    for res <- Results.show do
      case res do
        {:passed, msg, where} ->
          Logger.info "Passed: #{msg} Under: #{where}"

        {:failed, msg, where} ->
          Logger.error "Failed: #{msg} Under: #{where}"
      end
    end

    GenServer.stop Results
    Hound.end_session
    scenes
  end
end

# Yst.run
