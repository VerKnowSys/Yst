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


      @checks_list [
        :title?, :title_not?, :text?, :text_not?,
        :src?, :src_not?, :frame?, :frame_not?,
        :script?, :script_not?, :id?, :id_not?,
        :css?, :css_not?, :class?, :class_not?,
        :tag?, :tag_not?, :name?, :name_not?,
        :cookie?, :cookie_not?
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


      @doc """
      Check expectations
      """
      def expect request, scene, expectations do
        Results.push {:uuid, "#{scene.uuid}"}

        for expectation <- expectations do
          case expectation do

            {t, []} ->
              Logger.debug "Empty expectation: #{inspect expectation}. Ignored"


            {:at_least_single_action, true} ->
              Results.push {:success, "#{request} | Scene defines at least a single check!"}


            {:at_least_single_action, false} ->
              Results.push {:failure, "#{request} | Scene lacks any checks!"}


            {:title, entity_or_entities} ->
              if String.contains? page_title, entity_or_entities do
                Results.push {:success, "#{request} | Title contains element: #{inspect entity_or_entities}!"}
              else
                Results.push {:failure, "#{request} | Title lacks element: #{inspect entity_or_entities}!"}
              end


            {:title_not, entity_or_entities} ->
              unless String.contains? page_title, entity_or_entities do
                Results.push {:success, "#{request} | Title lacks element: #{inspect entity_or_entities}!"}
              else
                Results.push {:failure, "#{request} | Title contains element: #{inspect entity_or_entities}!"}
              end


            {:src, entity_or_entities} ->
              if String.contains? page_source, entity_or_entities do
                Results.push {:success, "#{request} | Elements present in page source: #{inspect entity_or_entities}!"}
              else
                Results.push {:failure, "#{request} | Elements absent in page source: #{inspect entity_or_entities}!"}
              end


            {:src_not, entity_or_entities} ->
              unless String.contains? page_source, entity_or_entities do
                Results.push {:success, "#{request} | Elements absent in page source: #{inspect entity_or_entities}!"}
              else
                Results.push {:failure, "#{request} | Elements present in page source: #{inspect entity_or_entities}!"}
              end


            {:text, entity_or_entities} ->
              if String.contains? visible_page_text, entity_or_entities do
                Results.push {:success, "#{request} | Elements present in page text: #{inspect entity_or_entities}!"}
              else
                Results.push {:failure, "#{request} | Elements absent in page text: #{inspect entity_or_entities}!"}
              end


            {:text_not, entity_or_entities} ->
              unless String.contains? visible_page_text, entity_or_entities do
                Results.push {:success, "#{request} | Elements absent in page text: #{inspect entity_or_entities}!"}
              else
                Results.push {:failure, "#{request} | Elements present in page text: #{inspect entity_or_entities}!"}
              end


            {:id, entity_list} ->
              for entity <- entity_list do
                if element? :id, entity do
                  Results.push {:success, "#{request} | Present element with ID: #{inspect entity}!"}
                else
                  Results.push {:failure, "#{request} | Absent element with ID: #{inspect entity}!"}
                end
              end

            {:id_not, entity_list} ->
              for entity <- entity_list do
                unless element? :id, entity do
                  Results.push {:success, "#{request} | Absent element with ID: #{inspect entity}!"}
                else
                  Results.push {:failure, "#{request} | Present element with ID: #{inspect entity}!"}
                end
              end


            {:class, entity_list} ->
              for entity <- entity_list do
                if element? :class, entity do
                  Results.push {:success, "#{request} | Present element with CLASS: #{inspect entity}!"}
                else
                  Results.push {:failure, "#{request} | Absent element with CLASS: #{inspect entity}!"}
                end
              end

            {:class_not, entity_list} ->
              for entity <- entity_list do
                unless element? :class, entity do
                  Results.push {:success, "#{request} | Absent element with CLASS: #{inspect entity}!"}
                else
                  Results.push {:failure, "#{request} | Present element with CLASS: #{inspect entity}!"}
                end
              end


            {:css, entity_list} ->
              for entity <- entity_list do
                if element? :css, entity do
                  Results.push {:success, "#{request} | Present element with CSS: #{inspect entity}!"}
                else
                  Results.push {:failure, "#{request} | Absent element with CSS: #{inspect entity}!"}
                end
              end

            {:css_not, entity_list} ->
              for entity <- entity_list do
                unless element? :css, entity do
                  Results.push {:success, "#{request} | Absent element with CSS: #{inspect entity}!"}
                else
                  Results.push {:failure, "#{request} | Present element with CSS: #{inspect entity}!"}
                end
              end


            {:name, entity_list} ->
              for entity <- entity_list do
                if element? :name, entity do
                  Results.push {:success, "#{request} | Present element with NAME: #{inspect entity}!"}
                else
                  Results.push {:failure, "#{request} | Absent element with NAME: #{inspect entity}!"}
                end
              end

            {:name_not, entity_list} ->
              for entity <- entity_list do
                unless element? :name, entity do
                  Results.push {:success, "#{request} | Absent element with NAME: #{inspect entity}!"}
                else
                  Results.push {:failure, "#{request} | Present element with NAME: #{inspect entity}!"}
                end
              end


            {:tag, entity_list} ->
              for entity <- entity_list do
                if element? :tag, entity do
                  Results.push {:success, "#{request} | Present TAG: #{inspect entity}!"}
                else
                  Results.push {:failure, "#{request} | Absent TAG: #{inspect entity}!"}
                end
              end

            {:tag_not, entity_list} ->
              for entity <- entity_list do
                unless element? :tag, entity do
                  Results.push {:success, "#{request} | Absent TAG: #{inspect entity}!"}
                else
                  Results.push {:failure, "#{request} | Present TAG: #{inspect entity}!"}
                end
              end


            {:script, entity_list} ->
              for entity <- entity_list do
                case execute_script entity do
                  true ->
                    Results.push {:success, "#{request} | SCRIPT succeeded: #{inspect entity}!"}
                  false ->
                    Results.push {:failure, "#{request} | SCRIPT failed: #{inspect entity}!"}
                end
              end

            {:script_not, entity_list} ->
              for entity <- entity_list do
                case execute_script entity do
                  true ->
                    Results.push {:failure, "#{request} | SCRIPT succeeded yet failure expected: #{inspect entity}!"}
                  false ->
                    Results.push {:success, "#{request} | SCRIPT failed as expected: #{inspect entity}!"}
                end
              end


            undefined ->
              Logger.warn "Undefined expectation: #{inspect expectation}"

          end
        end
      end


      @doc """
      Checks if at least one check is defined
      """
      def at_least_single_action scene, list \\ @checks_list do
        case list do
          [] ->
            Logger.warn "No checks defined for scene: #{inspect scene}!"
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
      def action_click! matchers, html_elems \\ [:partial_link_text, :name, :id, :class, :tag, :css] do
        for {html_entity, contents} <- matchers do
          Logger.debug "Looking for entity: #{html_entity} to click"
          for try_html_hook <- html_elems do
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
      def action_fill! matchers, html_elems \\ [:name, :id, :class, :tag, :css] do
        for {html_entity, contents} <- matchers do
          Logger.debug "Looking for entity: #{html_entity} to fill"
          for try_html_hook <- html_elems do
            if element? try_html_hook, html_entity do
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


      def action_pick! matchers do
        # TODO:

        # selected?(element)

      end


      def action_keys! matchers do
        for symbol <- matchers do
          Logger.debug "Sending keys: #{inspect symbol}"
          send_keys symbol
        end
      end


      def action_js! matchers do
        for code <- matchers do
          Logger.debug "Executing JavaScript code: #{inspect code}"
          execute_script "#{code}"
        end
      end


      @doc """
      Pipes defined scene expectations to expect() to produce Results
      """
      def check_expectations? request, scene do
        with  title <- scene.title?,    title_not <- scene.title_not?,
              scrpt <- scene.script?,   scrpt_not <- scene.script_not?,
              src <- scene.src?,        src_not <- scene.src_not?,
              text <- scene.text?,      text_not <- scene.text_not?,
              an_id <- scene.id?,       an_id_not <- scene.id_not?,
              a_class <- scene.class?,  a_class_not <- scene.class_not?,
              a_name <- scene.name?,    a_name_not <- scene.name_not?,
              a_css <- scene.css?,      a_css_not <- scene.css_not?,
              a_tag <- scene.tag?,      a_tag_not <- scene.tag_not?
          do
            expect request, scene, [
              at_least_single_action: (at_least_single_action scene),
              title: title, title_not: title_not,
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

        for {scene, act} <- script |> Enum.with_index do
          scene_id = scene.uuid
          request = scene.req!

          if scene.window! do
            Logger.debug "Setting window size to: #{inspect scene.window!}"
            set_window_size current_window_handle, scene.window![:width], scene.window![:height]
          end

          # Process pre-request options
          if scene.session! do
            change_session_to scene_id
            Logger.debug "Using session: #{scene_id}"
          else
            change_to_default_session
            Logger.debug "Using default session"
          end

          if scene.cookies_reset! do
            delete_cookies
            Logger.debug "Done cookies reset"
          end

          # Get driver info
          {:ok, drver} = Hound.driver_info

          navigate_to "#{url}#{request}"

          if scene.wait_after! > 0 do
            Logger.debug "Sleeping for: #{scene.wait_after!} seconds."
            :timer.sleep scene.wait_after!
          end

          session_info = Session.session_info Hound.current_session_id

          Logger.info "After Scene( #{act+1}/#{acts} ) Session( #{current_session_name} ) Url( #{url}#{request} )"
          Logger.debug "A\n\
                         scene_id: #{scene_id}\n\
                          request: #{inspect request}\n\
                       page_title: #{page_title}\n\
                      current_url: #{current_url}\n\
                          cookies: #{inspect Cookie.cookies}\n\
                       drver_info: #{inspect drver}\n\
                     session_info: #{inspect session_info}\n\
                     all_sessions: #{Enum.count(Session.active_sessions)}"

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
            Logger.debug "JavaScript disabled for scene: #{scene_id}"
          end

          if session_info[:handlesAlerts] do
            # accept! > dismiss!
            if scene.accept! do
              try do
                accept_dialog
                Logger.debug "Dialog accepted."
              rescue
                _ ->
                  Logger.warn "Accepting dialog failed."
              end
            else
              if scene.dismiss! do
                try do
                  dismiss_dialog
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
            Logger.debug "Screenshot: scene_id: #{scene_id}"
            Screenshot.take_screenshot "screenshots/sceneid-#{scene_id}.png"
          end


          ###########
          #   Checks
          ###############
          check_expectations? request, scene
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
