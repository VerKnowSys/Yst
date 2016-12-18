defmodule Scene do
  @moduledoc """
  This structure provides definition of "Scene".

  Each scene contains multiple actions and checks.
  Action is a field that ends with "!".
  Check is a field that ends with "?".

  Actions that may be defined once per scene:
  req!, window!, screenshot!, wait_after!,
  session!, dismiss!, accept!, cookies_reset!

  Some actions can be specified multiple times:
  fill!, click!, keys!, js!,

  All scene actions will be executed in given order.

  Each check should be specified only once.
  """
  @behaviour Access

  @type t :: Scene.t

  @enforce_keys [:req!]

  @default_delay_secs 0
  @default_user_agent :chrome_desktop
  @default_browser :chrome
  @default_window [width: 1920, height: 1080]


  @doc false
  def get keywords, key, default do
    res = Map.get keywords, key, []
    case res do
      {'EXIT', {:badarg, _}} -> default
      _ -> res
    end
  end


  @doc false
  def get_and_update list, key, fun do
    Map.get_and_update list, key, fun
  end


  @doc false
  def pop keywords, key do
    Map.pop keywords, key
  end


  @doc false
  def fetch keywords, key do
    res = Map.get keywords, key, []
    case res do
      {'EXIT', {:badarg, _}} -> :error
      _ -> {:ok, res}
    end
  end


  defstruct [

    name: UUID.uuid4,                       # by default set some unique name
    act: 0,                                 # act number
    actions_ms: 0,                          # time spent performing scene actions

    req!: "/",                              #  /some/request/and/http-params
    cookies_reset!: false,                  # reset cookies before request
    click!: [],                             # click on elements
    pick!: [],                              # pick an element from list of elements
    # focus!: [],                             # Set focus on element
    fill!: [],                              # fill focused field with content
    keys!: [],                              # send keystroke or key event
    js!: [],
    accept!: false,                         # Accept dialog or other js window
    dismiss!: false,                        # Dismiss dialog or other js window
    session!: false,                        # NO new session for each scene
    screenshot!: false,                     # make screenshot before first check
    wait_after!: @default_delay_secs,       # delay in seconds
    window!: @default_window,

    # browser!: @default_browser,
    # agent!: @default_user_agent,
    # wait_before!: @default_delay_secs,       # delay in seconds

    # After all sync tasks are done => perform expectations check
    attr?: [],                              # check element attribute value
    attr_not?: [],

    title?: [],
    title_not?: [],
    text?: [],
    text_not?: [],
    src?: [],
    src_not?: [],
    # frame?: [],                             # scene has content in these frames
    # frame_not?: [],
    script?: [],                            # JavaScript routines that have to return true
    script_not?: [],

    id?: [],
    id_not?: [],
    css?: [],
    css_not?: [],
    class?: [],
    class_not?: [],
    tag?: [],
    tag_not?: [],
    name?: [],
    name_not?: [],
    # attr?: [],                                # Tuple of argument and expected argument value content
    # attr_not?: [],
    # cookie?: [],                            # expect to find listed cookies
    # cookie_not?: [],                        # expect not to find listed cookies

    cookies?: true,                         # Enabled cookies?
    js?: true                               # Enabled javascript?
  ]

end


defimpl String.Chars, for: Scene do

  def to_string scene do
    "Scene {" <>
    "  name: '#{scene.name},' actions_ms: '#{scene.actions_ms},' act: '#{scene.act},'" <>
    "  title: '#{scene.title?}', title_not: '#{scene.title_not?}'," <>
    "  attr: #{scene.attr?}, attr_not: #{scene.attr_not?}," <>
    "  text: #{scene.text?}, text_not: #{scene.text_not?}," <>
    "  src: #{scene.src?}, src_not: #{scene.src_not?}," <>
    "  script: #{scene.script?}, script_not: #{scene.script_not?}," <>
    "  name: #{scene.name?}, name_not: #{scene.name_not?}" <>
    "  class: #{scene.class?}, class_not: #{scene.class_not?}," <>
    "  id: #{scene.id?}, id_not: #{scene.id_not?}," <>
    "  css: #{scene.css?}, css_not: #{scene.css_not?}," <>
    "  tag: #{scene.tag?}, tag_not: #{scene.tag_not?}" <>
    "}"
  end

end

