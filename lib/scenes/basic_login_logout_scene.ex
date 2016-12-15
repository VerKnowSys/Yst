defmodule BasicLoginLogoutScene do
  use Core

  @behaviour Scenario


  def script, do: [

      %Scene {
        req!: "/logout",
        cookies_reset!: true,

        id?: ["LoginForm", "Login"],
        tag?: ["fieldset", "input"],
        name?: ["fieldset", "input"],
      },

      %Scene {
        req!: "/login",
        fill!: [
          {"adm_user", user},
          {"adm_pass", pass},
        ],
        keys!: [:enter],
        screenshot!: true,

        title?: ["Dashboard - SilkVMS"],
        text_not?: ["Username", "Password"],
        class?: ["title", "fieldset"],
        id_not?: ["LoginForm", "Login"],
        tag?: ["fieldset", "input"],
        name?: ["fieldset", "input"],
      },

      %Scene {
        req!: "/",

        title?: ["Dashboard - SilkVMS"],
        text_not?: ["Username", "Password"],
        class?: ["title", "fieldset"],
        id_not?: ["LoginForm", "Login"],
        tag?: ["fieldset", "input"],
        name?: ["fieldset", "input"],
      },

  ]

end
