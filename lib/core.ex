defmodule Core do
  @moduledoc """
  Core defines set of functions and features
  to be injected to modules with Scenario behaviour
  """

  @callback url :: String.t


  defmacro __using__(_opts) do
    quote do

      use Hound.Helpers
      require Logger

      alias Hound.Session
      alias Hound.Helpers.Cookie
      alias Hound.Helpers.Screenshot
      alias :timer, as: Timer


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


      @doc ~S"""
      Performs match on given content. Accepted values are:
      "String" and ~/Regexp/

      ## Examples

          iex> "abc123 a123 AaBbCc123" |> Scenarios.content_matches? ~r/abc123/
          true

          iex> "a123 AaBbCc123" |> Scenarios.content_matches? "AaBbCc"
          true

          iex> "a123 AaBbCc123" |> Scenarios.content_matches? "aAbBcC"
          false

          iex> "a123 AaBbCc123" |> Scenarios.content_matches? ~r/.*Cc\d+/
          true

      """
      @spec content_matches?(contents :: list, matcher :: String.t | Regex.t) :: boolean
      def content_matches? contents, matcher do
        cond do
          # NOTE: String is a binary
          is_binary matcher ->
            String.contains? contents, matcher

          Regex.regex? matcher ->
            Regex.match? matcher, contents
        end
      end


      @doc """
      Check expectations
      """
      def expect scene, expectations do
        filtered = Enum.filter expectations, fn {_, value} -> value != [] end
        for expectation <- filtered do
          case expectation do

            {:at_least_single_action, true} ->
              Results.push {:success, scene, "Scene defines at least a single check!"}


            {:at_least_single_action, false} ->
              Results.push {:failure, scene, "Scene lacks any checks!"}


            {:title, entity_list} ->
              for entity <- entity_list do
                if content_matches? page_title(), entity do
                  Results.push {:success, scene, "Title contains element: #{inspect entity}!"}
                else
                  Results.push {:failure, scene, "Title lacks element: #{inspect entity}!"}
                end
              end

            {:title_not, entity_list} ->
              for entity <- entity_list do
                if content_matches? page_title(), entity do
                  Results.push {:failure, scene, "Title contains element: #{inspect entity}!"}
                else
                  Results.push {:success, scene, "Title lacks element: #{inspect entity}!"}
                end
              end


            {:src, entity_list} ->
              for entity <- entity_list do
                if content_matches? page_source(), entity do
                  Results.push {:success, scene, "Elements present in page source: #{inspect entity}!"}
                else
                  Results.push {:failure, scene, "Elements absent in page source: #{inspect entity}!"}
                end
              end

            {:src_not, entity_list} ->
              for entity <- entity_list do
                if content_matches? page_source(), entity do
                  Results.push {:failure, scene, "Elements present in page source: #{inspect entity}!"}
                else
                  Results.push {:success, scene, "Elements absent in page source: #{inspect entity}!"}
                end
              end


            {:text, entity_list} ->
              for entity <- entity_list do
                if content_matches? visible_page_text(), entity do
                  Results.push {:success, scene, "Elements present in page text: #{inspect entity}!"}
                else
                  Results.push {:failure, scene, "Elements absent in page text: #{inspect entity}!"}
                end
              end

            {:text_not, entity_list} ->
              for entity <- entity_list do
                if content_matches? visible_page_text(), entity do
                  Results.push {:failure, scene, "Elements present in page text: #{inspect entity}!"}
                else
                  Results.push {:success, scene, "Elements absent in page text: #{inspect entity}!"}
                end
              end


            {:attr, entity_list} ->
              for {html_entity, attribute, attr_value} <- entity_list do
                for try_html_hook <- @html_elems do
                  if element? try_html_hook, html_entity do
                    case search_element try_html_hook, html_entity do
                      {:ok, element} ->
                        if (attribute_value element, attribute) == attr_value do
                          Results.push {:success, scene, "Found attribute: #{inspect attribute}, value: #{inspect attr_value}!"}
                        else
                          Results.push {:failure, scene, "No attribute: #{inspect attribute}, value: #{inspect attr_value}!"}
                        end

                      {:error, e} ->
                        Logger.error e
                    end
                  end
                end
              end

            {:attr_not, entity_list} ->
              for {html_entity, attribute, attr_value} <- entity_list do
                for try_html_hook <- @html_elems do
                  if element? try_html_hook, html_entity do
                    case search_element try_html_hook, html_entity do
                      {:ok, element} ->
                        if (attribute_value element, attribute) != attr_value do
                          Results.push {:success, scene, "Element with attr: #{inspect attribute}, value: #{attr_value} is absent as expected!"}
                        else
                          Results.push {:failure, scene, "Unexpected element attr: #{inspect attribute}, value: #{attr_value}!"}
                        end

                      {:error, e} ->
                        Logger.error e
                    end
                  end
                end
              end


            {:url, entity_list} ->
              for entity <- entity_list do
                if content_matches? current_url(), entity do
                  Results.push {:success, scene, "URL matches expected: #{inspect entity}!"}
                else
                  Results.push {:failure, scene, "Expected no entry: #{inspect entity} in URL!"}
                end
              end

            {:url_not, entity_list} ->
              for entity <- entity_list do
                if not content_matches? current_url(), entity do
                  Results.push {:success, scene, "Expected no entry: #{inspect entity} in URL!"}
                else
                  Results.push {:failure, scene, "Expected absence of: #{inspect entity} in URL!"}
                end
              end


            {:id, entity_list} ->
              for entity <- entity_list do
                if element? :id, entity do
                  Results.push {:success, scene, "Present element with ID: #{inspect entity}!"}
                else
                  Results.push {:failure, scene, "Absent element with ID: #{inspect entity}!"}
                end
              end

            {:id_not, entity_list} ->
              for entity <- entity_list do
                if element? :id, entity do
                  Results.push {:failure, scene, "Present element with ID: #{inspect entity}!"}
                else
                  Results.push {:success, scene, "Absent element with ID: #{inspect entity}!"}
                end
              end


            {:class, entity_list} ->
              for entity <- entity_list do
                if element? :class, entity do
                  Results.push {:success, scene, "Present element with CLASS: #{inspect entity}!"}
                else
                  Results.push {:failure, scene, "Absent element with CLASS: #{inspect entity}!"}
                end
              end

            {:class_not, entity_list} ->
              for entity <- entity_list do
                if element? :class, entity do
                  Results.push {:failure, scene, "Present element with CLASS: #{inspect entity}!"}
                else
                  Results.push {:success, scene, "Absent element with CLASS: #{inspect entity}!"}
                end
              end


            {:css, entity_list} ->
              for entity <- entity_list do
                if element? :css, entity do
                  Results.push {:success, scene, "Present element with CSS: #{inspect entity}!"}
                else
                  Results.push {:failure, scene, "Absent element with CSS: #{inspect entity}!"}
                end
              end

            {:css_not, entity_list} ->
              for entity <- entity_list do
                if element? :css, entity do
                  Results.push {:failure, scene, "Present element with CSS: #{inspect entity}!"}
                else
                  Results.push {:success, scene, "Absent element with CSS: #{inspect entity}!"}
                end
              end


            {:name, entity_list} ->
              for entity <- entity_list do
                if element? :name, entity do
                  Results.push {:success, scene, "Present element with NAME: #{inspect entity}!"}
                else
                  Results.push {:failure, scene, "Absent element with NAME: #{inspect entity}!"}
                end
              end

            {:name_not, entity_list} ->
              for entity <- entity_list do
                if element? :name, entity do
                  Results.push {:failure, scene, "Present element with NAME: #{inspect entity}!"}
                else
                  Results.push {:success, scene, "Absent element with NAME: #{inspect entity}!"}
                end
              end


            {:tag, entity_list} ->
              for entity <- entity_list do
                if element? :tag, entity do
                  Results.push {:success, scene, "Present TAG: #{inspect entity}!"}
                else
                  Results.push {:failure, scene, "Absent TAG: #{inspect entity}!"}
                end
              end

            {:tag_not, entity_list} ->
              for entity <- entity_list do
                if element? :tag, entity do
                  Results.push {:failure, scene, "Present TAG: #{inspect entity}!"}
                else
                  Results.push {:success, scene, "Absent TAG: #{inspect entity}!"}
                end
              end


            {:script, entity_list} ->
              for entity <- entity_list do
                case execute_script entity do
                  true ->
                    Results.push {:success, scene, "SCRIPT succeeded: #{inspect entity}!"}
                  false ->
                    Results.push {:failure, scene, "SCRIPT failed: #{inspect entity}!"}
                end
              end

            {:script_not, entity_list} ->
              for entity <- entity_list do
                case execute_script entity do
                  true ->
                    Results.push {:failure, scene, "SCRIPT succeeded yet failure expected: #{inspect entity}!"}
                  false ->
                    Results.push {:success, scene, "SCRIPT failed as expected: #{inspect entity}!"}
                end
              end


            undefined ->
              Logger.warn "Undefined expectation: #{inspect expectation}"

          end
        end
      end


      @doc ~S"""
      Checks if at least one check is defined in scene struct

      ## Examples

          iex> BasicLoginLogoutScene.script |> (Enum.take 1) |> List.first |>Scenarios.at_least_single_action
          true

          iex> Scenarios.at_least_single_action Scenarios.script
          false

      """
      @spec at_least_single_action(scene :: Scene.t, list :: list) :: boolean
      def at_least_single_action(_, []), do: false
      def at_least_single_action([], _), do: false
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
                Logger.debug "At least some check: #{inspect head}, defined with: #{inspect checks}"
                true
            end
        end
      end


      @doc """
      Clicks on any element matching criteria
      """
      def action_click! matchers do
        for {html_entity, contents} <- matchers do
          Logger.debug "Looking for entity: #{html_entity} to click"
          for try_html_hook <- @html_elems ++ @html_elems_link do
            if element? try_html_hook, html_entity do
              case search_element try_html_hook, html_entity do
                {:ok, element} ->
                  Logger.debug "Click! entity: #{try_html_hook} => #{html_entity}. Click-Element: #{inspect element}"
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
              Logger.debug "Element: #{inspect html_entity} of type: #{inspect try_html_hook}"
              case search_element try_html_hook, html_entity do
                {:ok, element} ->
                  Logger.debug "Fill! entity: #{try_html_hook} => #{html_entity}. Element: #{inspect element}"
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
              Logger.debug "Picking element: #{inspect html_entity} of type: #{inspect try_html_hook}"
              case search_element try_html_hook, html_entity do
                {:ok, element} ->
                  Logger.debug "Pick!Click!"
                  click element
                  Logger.debug "Pick! entity: #{try_html_hook} => #{html_entity}. Element: #{inspect element}"
                  input_into_field element, contents # TODO: attribute_value(element, "value") == contents
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
          Logger.debug "Sending keys: #{inspect symbol}"
          send_keys symbol
        end
      end


      @doc """
      Executes JavaScript action block(s) on tested site.
      """
      def action_js! matchers do
        for code <- matchers do
          Logger.debug "Executing JavaScript code: #{inspect code}"
          execute_script "#{code}"
        end
      end


      @doc """
      Pipes defined scene expectations to expect() to produce Results
      """
      def check_expectations? scene do
        with  title <- scene.title?,    title_not <- scene.title_not?,
              attr <- scene.attr?,      attr_not <- scene.attr_not?,
              url <- scene.url?,        url_not <- scene.url_not?,
              scrpt <- scene.script?,   scrpt_not <- scene.script_not?,
              src <- scene.src?,        src_not <- scene.src_not?,
              text <- scene.text?,      text_not <- scene.text_not?,
              an_id <- scene.id?,       an_id_not <- scene.id_not?,
              a_class <- scene.class?,  a_class_not <- scene.class_not?,
              a_name <- scene.name?,    a_name_not <- scene.name_not?,
              a_css <- scene.css?,      a_css_not <- scene.css_not?,
              a_tag <- scene.tag?,      a_tag_not <- scene.tag_not?
          do
            expect scene, [
              at_least_single_action: (at_least_single_action scene),
              title: title, title_not: title_not,
              attr: attr, attr_not: attr_not,
              url: url, url_not: url_not,
              script: scrpt, script_not: scrpt_not,
              src: src, src_not: src_not,
              text: text, text_not: text_not,
              id: an_id, id_not: an_id_not,
              class: a_class, class_not: a_class_not,
              name: a_name, name_not: a_name_not,
              css: a_css, css_not: a_css_not,
              tag: a_tag, tag_not: a_tag_not
            ]
        end
      end


      @doc """
      Play scripted scenarios
      """
      @spec play(script :: [Scene.t]) :: any
      def play script do
        acts = length script
        Logger.info "Playing script of #{acts} acts."

        for {scene, act} <- script |> Enum.with_index() do
          # NOTE: fill act number
          scene = %Scene{scene | act: act + 1}

          # NOTE: count time spent on actions:
          {scene_actions_process_time, _} = Timer.tc fn ->
            if scene.window! do
              Logger.debug "Setting window size to: #{inspect scene.window!}"
              set_window_size current_window_handle, scene.window![:width], scene.window![:height]
            end

            # Process pre-request options
            if scene.session! do
              change_session_to scene.name
              Logger.debug "Using session: #{scene.name}"
            else
              Logger.debug "Using default session"
              change_to_default_session()
            end

            if scene.cookies_reset! do
              delete_cookies
              Logger.debug "Done cookies reset"
            end

            # Get driver info
            {:ok, drver} = Hound.driver_info()

            navigate_to "#{url()}#{scene.req!}"

            if scene.wait_after! > 0 do
              Logger.debug "Sleeping for: #{scene.wait_after!} seconds."
              :timer.sleep scene.wait_after!
            end

            session_info = Session.session_info Hound.current_session_id()

            Logger.info "After Scene( #{scene.act}/#{acts} ) Session( #{current_session_name} ) Url( #{url}#{scene.req!} )"
            Logger.debug "A\n\
                         scene.name: #{scene.name}\n\
                            request: #{inspect scene.req!}\n\
                         page_title: #{page_title()}\n\
                        current_url: #{current_url()}\n\
                            cookies: #{inspect Cookie.cookies}\n\
                         drver_info: #{inspect drver}\n\
                       session_info: #{inspect session_info}\n\
                       all_sessions: #{Enum.count(Session.active_sessions())}"

            # fill!
            action_fill! scene.fill!

            # click!
            action_click! scene.click!

            # select! / pick!
            action_pick! scene.pick!

            # js!
            if scene.js? do
              action_js! scene.js!
            else
              Logger.debug "JavaScript disabled for scene: #{scene.name}"
            end

            if session_info[:handlesAlerts] do
              # accept! > dismiss!
              if scene.accept! do
                try do
                  accept_dialog()
                  Logger.debug "Dialog accepted."
                rescue
                  _ ->
                    Logger.warn "Accepting dialog failed."
                end
              else
                if scene.dismiss! do
                  try do
                    dismiss_dialog()
                    Logger.debug "Dialog dismissed."
                  rescue
                    _ ->
                      Logger.warn "Dismissing dialog failed."
                  end
                end
              end
            else
              Logger.debug "handlesAlerts property is disabled with this browser session."
            end

            # keys!
            action_keys! scene.keys!

            # Good time to make a shot!
            if scene.screenshot! do
              Logger.debug "Screenshot: scene.name: #{scene.name}"
              Screenshot.take_screenshot "screenshots/sceneid-#{scene.name}.png"
            end
          end

          # NOTE: set value of actions_ms field of Scene struct.
          us_to_ms = div scene_actions_process_time, 1000
          scene = %Scene{scene | actions_ms: us_to_ms}

          ###########
          #   Fill Results queue
          #########################
          check_expectations? scene
        end

        # TODO: it should return Result.t site data like html, text, fields DOM & stuff
        {:ok, script}
      end


      @doc """
      Allow overriding only functions with corresponding arities
      """
      defoverridable [url: 0, user: 0, pass: 0, play: 1]

    end
  end

end
