defmodule ActionMacro do
  @moduledoc """
  ActionsMacro injects functions for Scene actions
  """


  defmacro __using__(_opts) do
    quote do


      @doc ~S"""
      Checks if at least one check is defined in scene struct

      ## Examples

          iex> BasicLoginLogoutScene.script() |> (Enum.take 1) |> List.first() |> Scenarios.at_least_single_action()
          true

          iex> Scenarios.at_least_single_action Scenarios.script()
          true

      """
      @spec at_least_single_action(scene :: Scene.t, list :: list) :: boolean
      def at_least_single_action(scene, list \\ @checks_list) do
        case list do
          [] ->
            Logger.warn "Scene lacks checks! - '#{scene.name}': #{inspect scene.name}!"
            false

          [head | tail] ->
            case scene[head] do
              [] ->
                at_least_single_action scene, tail

              checks ->
                Logger.debug fn -> "At least some check: #{inspect head}, defined with: #{inspect checks}" end
                true
            end
        end
      end


      @doc """
      Clicks on any element matching criteria
      """
      def action_click! matchers do
        for {html_entity, contents} <- matchers do
          Logger.debug fn -> "Looking for entity: #{html_entity} to click" end
          for try_html_hook <- @html_elems ++ @html_elems_link do
            if element? try_html_hook, html_entity do
              case search_element try_html_hook, html_entity do
                {:ok, element} ->
                  Logger.debug fn -> "Click! entity: #{try_html_hook} => #{html_entity}. Click-Element: #{inspect element}" end
                  click element

                {:error, e} ->
                  Logger.error e
              end
            end
          end
        end
      end


      @doc """
      Fills any element matching criteria
      """
      def action_fill! matchers do
        for {html_entity, contents} <- matchers do
          for try_html_hook <- @html_elems do
            if element? try_html_hook, html_entity do
              Logger.debug fn -> "Element: #{inspect html_entity} of type: #{inspect try_html_hook}" end
              case search_element try_html_hook, html_entity do
                {:ok, element} ->
                  Logger.debug fn -> "Fill! entity: #{try_html_hook} => #{html_entity}. Element: #{inspect element}" end
                  fill_field element, contents

                {:error, e} ->
                  Logger.error e
              end
            end
          end
        end
      end


      @doc """
      Picks checkbox, field, box, radio or select tag.
      """
      def action_pick! matchers do
        for {html_entity, contents} <- matchers do
          for try_html_hook <- @html_elems do
            if element? try_html_hook, html_entity do
              Logger.debug fn -> "Picking element: #{inspect html_entity} of type: #{inspect try_html_hook}" end
              case search_element try_html_hook, html_entity do
                {:ok, element} ->
                  Logger.debug fn -> "Pick entity: #{try_html_hook} => #{html_entity}. Element: #{inspect element}" end
                  click element
                  input_into_field element, contents

                  # TODO: attribute_value(element, "value") == contents
                  # TODO: selected?(element)

                {:error, e} ->
                  Logger.error e
              end
            end
          end
        end
      end


      @doc """
      Sends keyboard input(s) on tested site.
      """
      def action_keys! matchers do
        for symbol <- matchers do
          Logger.debug fn -> "Sending keys: #{symbol}" end
          send_keys symbol
        end
      end


      @doc """
      Executes JavaScript action block(s) on tested site.
      """
      def action_js! matchers do
        for code <- matchers do
          Logger.debug fn -> "Executing JavaScript code: #{code}" end
          execute_script "#{code}"
        end
      end


    end
  end

end
