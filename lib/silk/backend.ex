defmodule Silk.Backend do
  @moduledoc "Silk.Backend defines set of functions to be injected as features"

  @callback url :: String.t


  defmacro __using__(_opts) do
    quote do

      use Hound.Helpers
      require Logger

      alias Hound.Session
      alias Hound.Helpers.Cookie
      alias Hound.Helpers.Screenshot


      @doc """
      Defines base url of tested site
      """
      @spec url :: String.t
      def url, do: System.get_env "YS_URL"


      @doc """
      Defines username used on login panel
      """
      @spec user :: String.t
      def user, do: System.get_env "YS_LOGIN"


      @doc """
      Defines password used on login panel
      """
      @spec pass :: String.t
      def pass, do: System.get_env "YS_PASS"


      @doc """
      Defines site check callmap (loaded from "config.exs")
      """
      @spec callmap :: Keyword.t
      def callmap, do: Application.get_env :yst, :callmap


      @doc """
      Defines base navigation function.
      Each action and requirements are defined in "callmap"
      keyword loaded from "config.exs"
      """
      @spec go(action :: atom) :: String.t
      def go(action) when is_atom(action) do
        go action, callmap[action]
      end


      @doc """
      Defines base navigation function.
      Accepts "action_map" explicitly specified as second argument.
      """
      @spec go(action :: atom, action_map :: Keyword.t) :: String.t
      def go(action, action_map) when is_atom(action) do
        Logger.debug "NAV: '#{url}#{action_map[:rel]}'"
        navigate_to "#{url}#{action_map[:rel]}"
        if action == :login do
          if element? :name, "adm_user" do
            Logger.debug "LOGGING IN!"
            fill_field (find_element :name, "adm_user"), user
            fill_field (find_element :name, "adm_pass"), pass
            send_keys :enter
          else
            Logger.debug "ALREADY LOGGED IN!"
          end
        end
        curr = current_url
        {:ok, drver} = Hound.driver_info
        Logger.debug "\n\
                         action: #{inspect action}\n\
                     page_title: #{page_title}\n\
                    current_url: #{curr}\n\
                        cookies: #{inspect Cookie.cookies}\n\
                     drver_info: #{inspect drver}\n\
                   session_info: #{inspect Session.session_info Hound.current_session_id}\n\
                   all_sessions: #{Enum.count(Session.active_sessions)}"

        _ = Screenshot.take_screenshot "screenshots/post-action_#{action}.png"
        curr
      end


      @doc """
      Allow overriding only functions with corresponding arities
      """
      defoverridable [url: 0, user: 0, pass: 0, callmap: 0, go: 1]

    end
  end

end