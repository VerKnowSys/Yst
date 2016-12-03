defmodule SilkCommon do
  @moduledoc "SilkCommon defines set of functions to be injected as features"

  defmacro __using__(_opts) do
    quote do

      use Hound.Helpers
      require Logger

      alias Hound.Helpers.Cookie
      alias Hound.Helpers.Screenshot


      @doc """
      Defines base url of tested site
      """
      def url, do: System.get_env "YS_URL"


      @doc """
      Defines username used on login panel
      """
      def user, do: System.get_env "YS_LOGIN"


      @doc """
      Defines password used on login panel
      """
      def pass, do: System.get_env "YS_PASS"


      @doc """
      Defines site check callmap (loaded from "config.exs")
      """
      def callmap, do: Application.get_env :yst, :callmap


      @doc """
      Defines base navigation function.
      Each action and requirements are defined in "callmap" keyword loaded from "config.exs"
      """
      def go(action) when is_atom(action) do
        go action, callmap[action]
      end


      @doc """
      Defines base navigation function. Accepts "action_map" explicitly specified as second argument.
      """
      def go(action, action_map) when is_atom(action) do
        navigate_to "#{url}#{action_map[:rel]}"
        if action == :login do
          fill_field (find_element :name, "adm_user"), user
          fill_field (find_element :name, "adm_pass"), pass
          send_keys :enter
        end
        curr = current_url
        Logger.info "page_title: #{page_title}; action: #{inspect action}; current_url: #{curr}; cookies: #{inspect Cookie.cookies}"
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
