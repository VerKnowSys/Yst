defmodule YstTest do
  use ExUnit.Case
  use Hound.Helpers

  require Logger

  alias Hound.Browser.PhantomJS
  alias Hound.Helpers.Cookie

  doctest Yst


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
    in_browser_session "#{UUID.uuid4}", fn ->
      OddMollyDemo.go :login

      for item <- [~r/DASHBOARD - SALES/, ~r/GENERAL/, ~r/RETAIL/, ~r/Sales for period/, ~r/Accounts\/Customers: All/, ~r/SILK VMS master/] do
        assert visible_in_page? item
      end
    end
  end


  test "test sales elements existence" do
    in_browser_session "#{UUID.uuid4}", fn ->
      OddMollyDemo.go :login
      OddMollyDemo.go :sales

      assert (visible_in_page? ~r/SILK VMS master/), "'SILK VMS master' should be visible!"

      for item <- [~r/Total/, ~r/Order/, ~r/Customer/, ~r/Total/],
          elem <- [{:class, "fieldset"}] do
        assert (visible_in_page? item), "Item '#{inspect item}' should be visible!"
        assert (visible_in_element? elem, ~r/ORDERS/), "fieldset with ORDERS"
        assert (visible_in_element? elem, item), "Item #{inspect item} should be contained under element: #{inspect elem}"
      end
    end
  end


  test "test customers elements existence" do
    in_browser_session "#{UUID.uuid4}", fn ->
      OddMollyDemo.go :login
      OddMollyDemo.go :customers

      assert (visible_in_page? ~r/SILK VMS master/), "'SILK VMS master' should be visible!"
      assert (visible_in_element? {:id, "retail_customer_item"}, ~r/CUSTOMERS/), "retail_customer_item with CUSTOMERS"
      elem = find_element :class, "field_container"
      for item <- [~r/Orders/, ~r/Customer/, ~r/Total/, ~r/Created/] do
        assert (visible_in_element? elem, item), "Item #{inspect item} should be contained under element: #{inspect elem}"
        assert (visible_in_page? item), "Item '#{inspect item}' should be visible!"
      end
    end
  end


  test "cookie value should be shared across several logins/logouts" do
    in_browser_session "#{UUID.uuid4}", fn ->
      OddMollyDemo.go :logout

      OddMollyDemo.go :login
      OddMollyDemo.go :customers
      cookie_1 = (List.first Cookie.cookies)["value"]
      OddMollyDemo.go :logout

      OddMollyDemo.go :login
      OddMollyDemo.go :sales
      cookie_2 = (List.first Cookie.cookies)["value"]
      OddMollyDemo.go :logout

      OddMollyDemo.go :login
      OddMollyDemo.go :customers
      cookie_3 = (List.first Cookie.cookies)["value"]
      OddMollyDemo.go :logout

      Logger.debug "C1: #{cookie_1}, C2: #{cookie_2}, C3: #{cookie_3}, C*: #{inspect Cookie.cookies}"
      assert cookie_1 == cookie_2
      assert cookie_1 == cookie_3
    end
  end

end
