defmodule Yst do
  use Hound.Helpers


  def main, do: main []
  def main _ do
    run
  end


  def run do
    case Application.start :hound do
      :ok ->
        IO.puts "Hounds unleashed."

      {:error, cause} ->
        case cause do
          {:already_started, :hound} ->
            IO.puts "Hounds already unleased."

          {reason, :hound} ->
            IO.puts "ERROR: Hounds were lost. Cause: #{inspect reason}"
        end
    end

    Hound.start_session

    navigate_to "http://akash.im"
    IO.puts page_title()

    # Automatically invoked if the session owner process crashes
    Hound.end_session
  end
end

# Yst.run
