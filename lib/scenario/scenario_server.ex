defmodule ScenarioServer do
  use Maru.Router

  before do
    plug Plug.Logger
  end

  plug Plug.Parsers,
    pass: ["*/*"],
    json_decoder: Poison,
    parsers: [:urlencoded, :json, :multipart]

  resources do
    get do
      conn
      |> (json %{msg: "POST /scenario with 'content' html body param"})
    end

    mount ScenarioServerApi
  end


  rescue_from [MatchError, RuntimeError], with: :custom_error

  rescue_from :all do
    conn
      |> (put_status 500)
      |> (json %{msg: "Internal failure. Blame dmilith :)", error: true})
  end

  defp custom_error(conn, exception) do
    conn
      |> (put_status 500)
      |> (json %{msg: "#{exception}", error: true})
  end

end
