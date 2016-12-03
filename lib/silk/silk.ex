defmodule SilkCommon do

  defmacro __using__(_opts) do
    quote do

      use Hound.Helpers
      require Logger

      alias Hound.Helpers.Cookie
      alias Hound.Helpers.Screenshot


      def url, do: System.get_env "YS_URL"


      def go(param) when is_atom(param) do
        go param, callmap[param]
      end


      def go(action, action_map) when is_atom(action) do
        navigate_to "#{url}#{action_map[:rel]}"
        if action == :login do
          (find_element :name, "adm_user") |> (fill_field user)
          (find_element :name, "adm_pass") |> (fill_field pass)
          send_keys :enter
        end
        Logger.info "go: #{action} #{current_url}"
        Logger.info "go: #{action}.cookies: #{inspect Cookie.cookies}"
        _ = Screenshot.take_screenshot "screenshot-after:#{action}.png"
        current_url
      end


      defp user, do: System.get_env "YS_LOGIN"

      defp pass, do: System.get_env "YS_PASS"

      defp callmap, do: Application.get_env :yst, :callmap

      defoverridable [url: 0, user: 0, pass: 0, go: 1]

    end
  end

end
