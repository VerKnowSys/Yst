defmodule Yst.Silk do
  use Hound.Helpers

  alias Hound.Helpers.Cookie
  alias Hound.Helpers.Screenshot
  require Logger


  def url, do: "https://oddmollynew.youngskilled.com/ams"
  def demo_url, do: url


  def go_logout do
    navigate_to "#{demo_url}/sign_out"
    delete_cookies
    Logger.info "go_logout: #{current_url}"
    Logger.info "go_logout.cookies: #{inspect Cookie.cookies}"
    current_url
  end


  def go_sales do
    navigate_to "#{demo_url}/retail/sales?q=status:3"
    Logger.info "go_sales: #{current_url}"
    Logger.info "go_sales.cookies: #{inspect Cookie.cookies}"
    current_url
  end


  def go_customers do
    navigate_to "#{demo_url}/retail/customer?q=status:1"
    Logger.info "go_customers: #{current_url}"
    Logger.info "go_customers.cookies: #{inspect Cookie.cookies}"
    current_url
  end


  def go_login do
    user = System.get_env "YS_LOGIN"
    pass = System.get_env "YS_PASS"

    navigate_to demo_url
    (find_element :name, "adm_user") |> (fill_field user)
    (find_element :name, "adm_pass") |> (fill_field pass)
    send_keys :enter

    Logger.info "go_login: #{current_url}"
    Logger.info "go_login.cookies: #{inspect Cookie.cookies}"
    _ = Screenshot.take_screenshot "screenshot-go_login.png"
    current_url
  end

end
