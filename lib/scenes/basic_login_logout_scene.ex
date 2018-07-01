defmodule BasicLoginLogoutScene do
  @moduledoc """
  Scenario to test login, logout and login cookies
  """

  use Core

  @behaviour Scenario


  def script, do: [

      %Scene {
        name: "Logout-and-cookies-reset",
        req!: "/logout",
        cookies_reset!: true,

        # text?: [~r/Usernam/, ~r/Pa.*word/, "Pass"],
        text_not?: [~r/tr.*wr.*pr/, ~r/PaZ.*word/, "Pss"],
        # id?: ["LoginForm", "Login"],
        # tag?: ["fieldset", "input"],
        name_not?: ["fieldset", "input"],
      },

      %Scene {
        name: "Login-clean",
        req!: "/login",
        fill!: [
          {"adm_user", user()},
          {"adm_pass", pass()},
        ],
        keys!: [:enter],
        screenshot!: true,

        # title?: ["Cen"],
        title_not?: ["Belzebub", "Zdzisio"],
        text_not?: ["Username", "Password"],
        # class?: ["title", "fieldset"],
        id_not?: ["LoginForm", "Login"],
        # tag?: ["fieldset", "input"],
        name_not?: ["fieldset", "input"],
        url_not?: [~r/silkvms/],
      },

      %Scene {
        name: "Main-site-after-login",
        req!: "/",

        # title?: ["Cen"],
        text_not?: ["Username", "Password"],
        # class?: ["title", "fieldset"],
        id_not?: ["LoginForm", "Login"],
        # tag?: ["fieldset", "input"],
        name_not?: ["fieldset", "input"],
        attr?: [
          {"whole_queryLowerListFilter", "value", "page:1"},
        ],
      },

  ]

end
