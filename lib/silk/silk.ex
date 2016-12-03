defmodule Yst.Silk do
  use Hound.Helpers

  # import Hound.RequestUtils
  # alias Hound.Helpers.Screenshot

  require Logger


  def go_login silk_url do
    user = System.get_env "YS_LOGIN"
    pass = System.get_env "YS_PASS"

    navigate_to silk_url
    (find_element :name, "adm_user") |> (fill_field user)
    (find_element :name, "adm_pass") |> (fill_field pass)
    send_keys :enter

    silk_url
  end


  def go_logout silk_url do
    navigate_to "/sign_out"
    delete_cookies
    silk_url
  end


  def go_sales silk_url do
    navigate_to "/retail/sales?q=status:3"
    silk_url
  end


  def go_customers silk_url do
    navigate_to "/retail/customer?q=status:1"
    silk_url
  end


  def pick_demo client \\ :oddmollydemo do
    case client do
      _ -> "https://oddmollynew.youngskilled.com/ams"
    end
  end

end
