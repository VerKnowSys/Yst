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

    GenServer.stop Results
  end


  # test "test customers elements existence" do
  #   in_browser_session "#{UUID.uuid4}", fn ->
  #     PeterDemo.go :login
  #     PeterDemo.go :customers

  #     assert (visible_in_page? ~r/SILK VMS master/), "'SILK VMS master' should be visible!"
  #     assert (visible_in_element? {:id, "retail_customer_item"}, ~r/CUSTOMERS/), "retail_customer_item with CUSTOMERS"
  #     elem = find_element :class, "field_container"
  #     for item <- [~r/Orders/, ~r/Customer/, ~r/Total/, ~r/Created/] do
  #       assert (visible_in_element? elem, item), "Item #{inspect item} should be contained under element: #{inspect elem}"
  #       assert (visible_in_page? item), "Item '#{inspect item}' should be visible!"
  #     end
  #   end
  # end


  # test "cookie value should be shared across several logins/logouts" do
  #   in_browser_session "#{UUID.uuid4}", fn ->
  #     PeterDemo.go :logout

  #     PeterDemo.go :login
  #     PeterDemo.go :customers
  #     cookie_1 = (List.first Cookie.cookies)["value"]
  #     PeterDemo.go :logout

  #     PeterDemo.go :login
  #     PeterDemo.go :sales
  #     cookie_2 = (List.first Cookie.cookies)["value"]
  #     PeterDemo.go :logout

  #     PeterDemo.go :login
  #     PeterDemo.go :customers
  #     cookie_3 = (List.first Cookie.cookies)["value"]
  #     PeterDemo.go :logout

  #     Logger.debug "C1: #{cookie_1}, C2: #{cookie_2}, C3: #{cookie_3}, C*: #{inspect Cookie.cookies}"
  #     assert cookie_1 == cookie_2
  #     assert cookie_1 == cookie_3
  #   end
  # end

end
