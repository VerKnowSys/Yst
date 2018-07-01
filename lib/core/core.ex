defmodule Core do
  @moduledoc """
  Core defines set of functions and features
  to be injected to modules with Scenario behaviour
  """

  @callback url :: String.t


  defmacro __using__(_opts) do
    quote do


      @checks_list [
        :title?, :title_not?, :text?, :text_not?,
        :src?, :src_not?, :frame?, :frame_not?,
        :script?, :script_not?, :id?, :id_not?,
        :css?, :css_not?, :class?, :class_not?,
        :tag?, :tag_not?, :name?, :name_not?,
        :cookie?, :cookie_not?
      ]

      @html_elems_link [
        :partial_link_text,
        :link_text
      ]

      @html_elems [
        :xpath,
        :name,
        :class,
        :id,
        :css,
        :tag,
      ]


      use CoreMacro


      @doc """
      Allow overriding only functions with corresponding arities
      """
      defoverridable [url: 0, user: 0, pass: 0, play: 1]

    end
  end

end
