defmodule ScenarioPlayMacro do
  @moduledoc """
  ScenarioPlayMacro injects play() function for Scenario
  """


  defmacro __using__(_opts) do
    quote do


      alias Hound.Session
      alias Hound.Helpers.Cookie
      alias Hound.Helpers.Screenshot
      alias :timer, as: Timer


      @doc """
      Play scripted scenarios
      """
      @spec play(script :: [Scene.t]) :: any
      def play script do
        acts = length script
        Logger.info "Playing script of #{acts} acts."

        for {scene, act} <- (script |> Enum.with_index()) do
          # NOTE: fill act number
          scene = %Scene{scene | act: act + 1}

          # NOTE: count time spent on actions:
          {scene_actions_process_time, _} = Timer.tc fn ->
            if scene.window! do
              Logger.debug fn -> "Setting Phantom window size to: #{inspect scene.window!}" end
              set_window_size current_window_handle(), scene.window![:width], scene.window![:height]
            end

            # Process pre-request options
            if scene.session! do
              change_session_to scene.name
              Logger.debug fn -> "Changed session to scene: #{scene.name}" end
            else
              change_to_default_session()
              Logger.debug fn -> "Changed session to default" end
            end

            if scene.cookies_reset! do
              delete_cookies()
              Logger.debug fn -> "Done cookies wipeout" end
            end

            # Get driver info
            {:ok, drver} = Hound.driver_info()

            navigate_to "#{url()}#{scene.req!}"

            if scene.wait_after! > 0 do
              Logger.debug fn -> "Sleeping for: #{scene.wait_after!} seconds." end
              :timer.sleep scene.wait_after!
            end

            session_info = Session.session_info Hound.current_session_id()

            Logger.info "After Scene( #{scene.act}/#{acts} ) Session( #{current_session_name()} ) Url( #{url()}#{scene.req!} )"
            Logger.debug fn -> "A\n\
               scene.name: #{scene.name}\n\
                  request: #{inspect scene.req!}\n\
               page_title: #{page_title()}\n\
              current_url: #{current_url()}\n\
                  cookies: #{inspect Cookie.cookies}\n\
               drver_info: #{inspect drver}\n\
             session_info: #{inspect session_info}\n\
             all_sessions: #{Enum.count(Session.active_sessions())}"
            end

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
              Logger.info "JavaScript disabled for scene: #{scene.name}"
            end

            if session_info[:handlesAlerts] do
              # accept! > dismiss!
              if scene.accept! do
                try do
                  accept_dialog()
                  Logger.debug fn -> "Dialog accepted." end
                rescue
                  _ ->
                    Logger.warn "Accepting dialog failed."
                end
              else
                if scene.dismiss! do
                  try do
                    dismiss_dialog()
                    Logger.debug fn -> "Dialog dismissed." end
                  rescue
                    _ ->
                      Logger.warn "Dismissing dialog failed."
                  end
                end
              end
            else
              Logger.debug fn -> "handlesAlerts property is disabled with this browser session." end
            end

            # keys!
            action_keys! scene.keys!

            # Good time to make a shot!
            if scene.screenshot! do
              Logger.info fn -> "Screenshot: scene.name: #{scene.name}" end
              Screenshot.take_screenshot "screenshots/sceneid-#{scene.name}.png"
            end
          end

          # NOTE: set value of actions_ms field of Scene struct.
          us_to_ms = div scene_actions_process_time, 1000
          scene = %Scene{scene | actions_ms: us_to_ms}

          # Fill Results queue
          check_expectations? scene
        end

        # TODO: it should return Result.t site data like html, text, fields DOM & stuff
        {:ok, script}
      end


    end
  end


end
