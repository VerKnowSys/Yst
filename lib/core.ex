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
      Check expected values
      """
      def expect request, statement, description \\ "" do
        case statement do
          true ->
            Logger.info "Pass:(#{statement}): #{inspect description}"
            Results.push {:passed, description, "@: #{url}#{request}"}

          false ->
            Logger.error "Fail:(#{statement}): #{inspect description}"
            Results.push {:failed, description, "@: #{url}#{request}"}

          any ->
            Logger.warn "WrongArgument:(#{statement}): #{inspect any}"
            Results.push {:failed, description, "@: #{url}#{request}"}
        end
      end


      @doc """
      Checks if at least one check is defined
      """
      def at_least_one_defined scene, list \\ @checks_list do
        case list do
          [] ->
            Logger.warn "No checks defined for scene: #{inspect scene}!"
            false

          [head | tail] ->
            case scene[head] do
              [] ->
                at_least_one_defined scene, tail

              checks ->
                Logger.debug "At least some check: #{inspect head}, defined with: #{inspect checks}"
                true
            end
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
          scene_id = UUID.uuid4
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

          # Logger.info "Before Scene( #{act+1}/#{acts} ) Session( #{current_session_name} ) Url( #{url}#{request} )"
          # Logger.debug "B\n\
          #                 request: #{inspect request}\n\
          #              page_title: #{page_title}\n\
          #             current_url: #{current_url}\n\
          #                 cookies: #{inspect Cookie.cookies}\n\
          #              drver_info: #{inspect drver}\n\
          #            session_info: #{inspect Session.session_info Hound.current_session_id}\n\
          #            all_sessions: #{Enum.count(Session.active_sessions)}"

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
          for {html_entity, contents} <- scene.fill! do
            Logger.debug "Looking for entity: #{html_entity} to fill"
            for try_html_hook <- [:name, :id, :class] do # , :tag, :css
              if element? try_html_hook, html_entity do
                case search_element try_html_hook, html_entity do
                  {:ok, element} ->
                    Logger.debug "Found entity: #{try_html_hook} => #{html_entity}. Element: #{inspect element}"
                    fill_field element, contents

                  {:error, e} ->
                    Logger.error e

                end
              end
            end
          end


          # click!
          for {html_entity, contents} <- scene.click! do
            Logger.debug "Looking for entity: #{html_entity} to click"
            for try_html_hook <- [:link_text, :name, :id, :class, :tag, :css] do
              if element? try_html_hook, html_entity do
                case search_element try_html_hook, html_entity do
                  {:ok, element} ->
                    Logger.debug "Found entity: #{try_html_hook} => #{html_entity}. Click-Element: #{inspect element}"
                    click element

                  {:error, e} ->
                    Logger.error e

                end
              end
            end
          end


          # js!
          if scene.js? do
            for code <- scene.js! do
              Logger.debug "Executing JavaScript code: #{inspect code}"
              execute_script "#{code}"
            end
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
          for symbol <- scene.keys! do
            Logger.debug "Sending keys: #{inspect symbol}"
            send_keys symbol
          end

          # Good time to make a shot!
          if scene.screenshot! do
            Logger.debug "Screenshot: scene_id: #{scene_id}"
            Screenshot.take_screenshot "screenshots/sceneid-#{scene_id}.png"
          end


          ###########
          #   Checks
          ###############

          expect request, (at_least_one_defined scene), "At least one check should be defined for each scene."

          for title <- scene.title? do
            Logger.debug "CheckTitle:(#{title})"
            expect request, (String.contains page_title, title), "Title must contain: '#{title}'"
          end
          for title <- scene.title_not? do
            Logger.debug "CheckTitleNot:(#{title})"
            expect request, not (String.contains page_title, title), "Title mustn't contain: '#{title}'"
          end

          for scrpt <- scene.script? do
            Logger.debug "CheckScript:(#{inspect scrpt})"
            expect request, (execute_script "#{scrpt}"), "Script must return true"
          end
          for scrpt <- scene.script_not? do
            Logger.debug "CheckScriptNot:(#{inspect scrpt})"
            expect request, not (execute_script "#{scrpt}"), "Script mustn't return true"
          end

          for src <- scene.src? do
            Logger.debug "CheckSrc:(#{inspect src})"
            expect request, (String.contains? page_source, src), "Page source must contain '#{src}'"
          end
          for src <- scene.src_not? do
            Logger.debug "CheckSrcNot:(#{inspect src})"
            expect request, not (String.contains? page_source, src), "Page source mustn't contain '#{src}'"
          end

          for text <- scene.text? do
            Logger.debug "CheckText:(#{inspect text})"
            expect request, (String.contains? visible_page_text, text), "Page text must contain '#{text}'"
          end
          for text <- scene.text_not? do
            Logger.debug "CheckTextNot:(#{inspect text})"
            expect request, not (String.contains? visible_page_text, text), "Page text mustn't contain '#{text}'"
          end

          for an_id <- scene.id? do
            Logger.debug "CheckId:(#{inspect an_id})"
            expect request, (element? :id, an_id), "Page ID element must exist: '#{an_id}'"
          end
          for an_id <- scene.id_not? do
            Logger.debug "CheckIdNot:(#{inspect an_id})"
            expect request, not (element? :id, an_id), "Page ID element mustn't exist: '#{an_id}'"
          end

          for a_class <- scene.class? do
            Logger.debug "CheckClass:(#{inspect a_class})"
            expect request, (element? :class, a_class), "Page CLASS element must exist: '#{a_class}'"
          end
          for a_class <- scene.class_not? do
            Logger.debug "CheckClassNot:(#{inspect a_class})"
            expect request, not (element? :class, a_class), "Page CLASS element mustn't exist: '#{a_class}'"
          end

          for a_name <- scene.name? do
            Logger.debug "CheckName:(#{inspect a_name})"
            expect request, (element? :name, a_name), "Page NAME element must exist: '#{a_name}'"
          end
          for a_name <- scene.name_not? do
            Logger.debug "CheckNameNot:(#{inspect a_name})"
            expect request, not (element? :name, a_name), "Page NAME element mustn't exist: '#{a_name}'"
          end

          for a_css <- scene.css? do
            Logger.debug "CheckCSS:(#{inspect a_css})"
            expect request, (element? :css, a_css), "Page CSS element must exist: '#{a_css}'"
          end
          for a_css <- scene.css_not? do
            Logger.debug "CheckCSSNot:(#{inspect a_css})"
            expect request, not (element? :css, a_css), "Page CSS element mustn't exist: '#{a_css}'"
          end

          for a_tag <- scene.tag? do
            Logger.debug "CheckTag:(#{inspect a_tag})"
            expect request, (element? :tag, a_tag), "Page TAG element must exist: '#{a_tag}'"
          end
          for a_tag <- scene.tag_not? do
            Logger.debug "CheckTagNot:(#{inspect a_tag})"
            expect request, not (element? :tag, a_tag), "Page TAG element mustn't exist: '#{a_tag}'"
          end

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
