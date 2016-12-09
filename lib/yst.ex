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


    Hound.start_session

    scenes = BasicLoginLogoutScene.script
    scenes |> BasicLoginLogoutScene.play

    Hound.end_session
    scenes
  end
end

# Yst.run
