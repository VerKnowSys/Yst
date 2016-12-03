defmodule Yst do
  @moduledoc "YoungSkilled OST"

  require Logger

  alias Yst.Silk

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

    Silk.go_login
    Logger.info "Title go_login: #{page_title}"
    _ = Screenshot.take_screenshot "after-login.png"

    Silk.go_sales
    Logger.info "Title go_sales: #{page_title}"
    _ = Screenshot.take_screenshot "after-sales.png"

    Silk.go_customers
    Logger.info "Title go_customers: #{page_title}"
    _ = Screenshot.take_screenshot "after-customers.png"

    Silk.go_logout
    Logger.info "Title go_logout: #{page_title}"
    _ = Screenshot.take_screenshot "after-logout.png"

    # Automatically invoked if the session owner process crashes
    Hound.end_session
  end
end

# Yst.run
