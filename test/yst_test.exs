defmodule YstTest do
  use ExUnit.Case
  use Hound.Helpers

  import Hound.RequestUtils

  alias Hound.Element
  alias Hound.Browser.PhantomJS
  alias Hound.Helpers.Screenshot
  alias Hound.Helpers.Orientation


  doctest Yst


  # hound_session

  setup do
    Hound.start_session

    parent = self
    on_exit fn ->
      Hound.end_session parent
    end
    :ok
  end


  test "user_agent capabilities check" do
    for user_agent <- [:iphone, :chrome, :firefox, :android] do
      ua = Hound.Browser.user_agent user_agent
      assert (PhantomJS.user_agent_capabilities ua) == %{"phantomjs.page.settings.userAgent" => ua}
    end
  end


  test "each checked page has to pass content validations" do
    _ = Hound.Browser.user_agent :iphone
    # set_window_size current_window_handle, 2560, 2048

    url1 = "https://hexdocs.pm/hound/Hound.Helpers.Screenshot.html"
    navigate_to url1

    for item <- [~r/Functions/, ~r/Built using/, ~r/The screenshot is saved in the current working directory/] do
      assert visible_in_page? item
    end
    assert visible_in_element? {:class, "section-heading"}, ~r/Summary/

    Screenshot.take_screenshot "screenshots-url1.png"
  end


end
