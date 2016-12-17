defmodule YstTest do
  use ExUnit.Case
  use Hound.Helpers

  require Logger

  alias Hound.Browser.PhantomJS

  doctest Yst
  doctest Scenarios
  doctest ScenesList


  hound_session


  test "user_agent capabilities check and driver details" do
    in_browser_session "#{UUID.uuid4}", fn ->
      for user_agent <- [:iphone, :chrome, :firefox, :android] do
        ua = Hound.Browser.user_agent user_agent
        assert (PhantomJS.user_agent_capabilities ua) == %{"phantomjs.page.settings.userAgent" => ua}
      end

      {:ok, driver_info} = Hound.driver_info
      assert driver_info[:driver] == "phantomjs"
      assert driver_info[:browser] == "phantomjs"
    end
  end


  test "each checked page has to pass content validations" do
    scenes = HeadlessScene.script

    res = scenes |> Scenarios.play
    assert res == {:ok, scenes}
    assert (length scenes) == 2
  end


  test "test if results queue is filled" do
    case Results.start_link do
      {:ok, pid} ->
        Logger.info "Results queue started (#{inspect pid})"

      {:error, {:already_started, pid}} ->
        Logger.debug "Results queue already started with pid: #{inspect pid}"

      {:error, er} ->
        Logger.error "Error happened: #{inspect er}"
    end

    scenes = HeadlessScene.script ++ BasicLoginLogoutScene.script

    res = scenes |> Scenarios.play
    assert res == {:ok, scenes}
    assert (length scenes) >= 5
    assert (length Results.show) >= 5
  end


  test "Director results after run may not be empty!" do
    _ = Results.start_link
    scenes = BasicLoginLogoutScene.script
    res = scenes |> Scenarios.play
    assert res == {:ok, scenes}, "Response with :ok and scenes"

    for {result, scene, message} <- Results.show do
      assert result == :success, "Each test result has to be successful!"

      case message do
        "" ->
          assert false, "Results message can't be empty!"

        any ->
          assert (String.length any) > 0, "Results message can't have zero length!"
      end

      at_least_same_name = Enum.find scenes, fn scn -> scn[:name] == scene[:name] end
      assert at_least_same_name, "Each processed scene should be present in Results"

      # NOTE: Initial actions_ms => 0. We fill that value to time spent on "clicking actions"
      non_zero_action_time = Enum.find scenes, fn scn ->
        scene[:actions_ms] > 50 and scn[:actions_ms] == 0
      end
      assert non_zero_action_time, "Each processed scene should always have :actions_ms field set > 0"
    end
  end


end
