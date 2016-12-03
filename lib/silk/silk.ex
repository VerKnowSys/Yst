defmodule SilkCommon do

  defmacro __using__(_opts) do
    quote do

      use Hound.Helpers
      require Logger

      alias Hound.Helpers.Cookie
      alias Hound.Helpers.Screenshot


      def url, do: System.get_env "YS_URL"

      defp user, do: System.get_env "YS_LOGIN"

      defp pass, do: System.get_env "YS_PASS"

      defp callmap, do: [
        login: [
          rel: "/login",
          expected: [~r/SIGN IN/, ~r/Username/, ~r/Password/],
          input: [
            user: user,
            pass: pass,
          ],
        ],

        logout: [
          rel: "/sign_out",
          expected: [~r/SIGN IN/, ~r/Username/, ~r/Password/],
        ],

        sales: [
          rel: "/retail/sales?q=status:3",
          expected: [~r/Total/, ~r/Order/, ~r/Customer/, ~r/Total/],
        ],

        customers: [
          rel: "/retail/customer?q=status:1",
          expected: [~r/Orders/, ~r/Customer/, ~r/Total/, ~r/Created/],
        ],
      ]


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


      defoverridable [url: 0, go: 1, callmap: 0]
    end
  end

end
