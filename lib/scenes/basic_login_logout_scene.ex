defmodule BasicLoginLogoutScene do
  use Core

  @behaviour Scenario


  def script, do: [

      %Scene {
        uuid: "Logout-and-cookies-reset",
        req!: "/logout",
        cookies_reset!: true,

        text?: ["Username", "Password"],
        id?: ["LoginForm", "Login"],
        tag?: ["fieldset", "input"],
        name_not?: ["fieldset", "input"],
      },

      %Scene {
        uuid: "Login-clean",
        req!: "/login",
        fill!: [
          {"adm_user", user},
          {"adm_pass", pass},
        ],
        keys!: [:enter],
        screenshot!: true,

        title?: ["Dashboard", "SilkVMS"],
        title_not?: ["Belzebub", "Zdzisio"],
        text_not?: ["Username", "Password"],
        class?: ["title", "fieldset"],
        id_not?: ["LoginForm", "Login"],
        tag?: ["fieldset", "input"],
        name_not?: ["fieldset", "input"],
      },

      %Scene {
        uuid: "Main-site-after-login",
        req!: "/",

        title?: ["Dashboard", "SilkVMS"],
        text_not?: ["Username", "Password"],
        class?: ["title", "fieldset"],
        id_not?: ["LoginForm", "Login"],
        tag?: ["fieldset", "input"],
        name_not?: ["fieldset", "input"],
      },

  ]

end
