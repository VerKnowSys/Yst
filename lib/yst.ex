defmodule Yst do
  @moduledoc "YoungSkilled OST"

  require Logger

  use Hound.Helpers
  alias Hound.Helpers.Screenshot


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
    Logger.info "Title go :login: #{page_title}"
    _ = Screenshot.take_screenshot "after-login.png"

    OddMollyDemo.go :sales
    Logger.info "Title go :sales: #{page_title}"
    _ = Screenshot.take_screenshot "after-sales.png"

    OddMollyDemo.go :customers
    Logger.info "Title go :customers: #{page_title}"
    _ = Screenshot.take_screenshot "after-customers.png"

    OddMollyDemo.go :logout
    Logger.info "Title go :logout: #{page_title}"
    _ = Screenshot.take_screenshot "after-logout.png"

    # Automatically invoked if the session owner process crashes
    Hound.end_session
  end
end

# Yst.run
