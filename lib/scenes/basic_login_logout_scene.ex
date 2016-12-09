defmodule BasicLoginLogoutScene do
  use Silk.Backend

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

        title?: ["SIGN IN"],
        text_not?: ["Username", "Password"],
        class?: ["title", "fieldset"],
        id_not?: ["LoginForm", "Login"],
        tag?: ["fieldset", "input"],
        name?: ["fieldset", "input"],
      },

      %Scene {
        req!: "/",

        text_not?: ["Username", "Password"],
        class?: ["title", "fieldset"],
        id_not?: ["LoginForm", "Login"],
        tag?: ["fieldset", "input"],
        name?: ["fieldset", "input"],
      },

  ]

end
