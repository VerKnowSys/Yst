defmodule ScenarioServerApi do
  require Logger
  use Maru.Router
  use TransactMacro


  namespace :scenario do
    desc "Recorded Scenario"
    params do
      requires :content, type: String, default: ""
      # optional :intro,  type: String, regexp: ~r/^[a-z]+$/
      # optional :avatar, type: File
      # optional :avatar_url, type: String
      exactly_one_of [:content]
    end

    post do
      Logger.debug "Got content: #{inspect params[:content]}"

      transact RecordedScenario.write! DbApi.scenario_new params[:content]

      conn
      |> (json %{msg: "Scenario stored. Thank You! :)"})
    end
  end
end
