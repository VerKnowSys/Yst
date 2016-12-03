defmodule Yst do
  @moduledoc "YoungSkilled OST"

  require Logger

  use Hound.Helpers


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

    OddMollyDemo.go :login
    OddMollyDemo.go :sales
    OddMollyDemo.go :customers
    OddMollyDemo.go :logout

    # Automatically invoked if the session owner process crashes
    Hound.end_session
  end
end

# Yst.run
