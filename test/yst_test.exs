defmodule YstTest do
  use ExUnit.Case
  use Hound.Helpers

  alias Hound.Browser.PhantomJS
  alias Yst.Silk

  doctest Yst


  hound_session


  test "user_agent capabilities check" do
    for user_agent <- [:iphone, :chrome, :firefox, :android] do
      ua = Hound.Browser.user_agent user_agent
      assert (PhantomJS.user_agent_capabilities ua) == %{"phantomjs.page.settings.userAgent" => ua}
    end
  end


  test "each checked page has to pass content validations" do
    Silk.pick_demo |> Silk.go_login

    for item <- [~r/DASHBOARD - SALES/, ~r/GENERAL/, ~r/RETAIL/, ~r/Sales for period/, ~r/Accounts\/Customers: All/, ~r/SILK VMS master/] do
      assert visible_in_page? item
    end

    Silk.pick_demo |> Silk.go_logout
  end


  test "test sales elements existence" do
    Silk.pick_demo |> Silk.go_login |> Silk.go_sales

    assert (visible_in_page? ~r/SILK VMS master/), "'SILK VMS master' should be visible!"

    for item <- [~r/Total/, ~r/Order/, ~r/Customer/, ~r/Total/],
        elem <- [{:class, "fieldset"}] do
      assert (visible_in_page? item), "Item '#{inspect item}' should be visible!"
      assert (visible_in_element? elem, ~r/ORDERS/), "fieldset with ORDERS"
      assert (visible_in_element? elem, item), "Item #{inspect item} should be contained under element: #{inspect elem}"
    end

    Silk.pick_demo |> Silk.go_logout
  end


  test "test customers elements existence" do
    Silk.pick_demo |> Silk.go_login |> Silk.go_customers

    assert (visible_in_page? ~r/SILK VMS master/), "'SILK VMS master' should be visible!"
    assert (visible_in_element? {:id, "retail_customer_item"}, ~r/CUSTOMERS/), "retail_customer_item with CUSTOMERS"
    elem = find_element :class, "field_container"
    for item <- [~r/Orders/, ~r/Customer/, ~r/Total/, ~r/Created/] do
      assert (visible_in_element? elem, item), "Item #{inspect item} should be contained under element: #{inspect elem}"
      assert (visible_in_page? item), "Item '#{inspect item}' should be visible!"
    end

    Silk.pick_demo |> Silk.go_logout
  end


end
