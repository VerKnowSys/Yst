defmodule HeadlessScene do
  use Core

  @behaviour Scenario


  def script, do: [

      %Scene {
        req!: "/",
        js!: ["return window.isItReal = confirm('Is it true?')"],
        script_not?: ["return window.isItReal"],
      },

      %Scene {
        req!: "/",
        js!: ["return alert('Is it true?')"],
        dismiss!: true,
      },

  ]

end
