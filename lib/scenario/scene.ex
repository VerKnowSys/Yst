defmodule Scene do
  @moduledoc """
  Defines main Scene structure.

  This struct is used to define scene expectations
  """

  @type t :: Scene.t

  @enforce_keys [:req!]

  @default_delay_secs 0
  @default_user_agent :chrome_desktop
  @default_browser :chrome


  defstruct code: [200..210],     # -200-202 => default success codes
            window: [x: 100, y: 100, w: 1920, h: 1080],

            # ui_actions:
            req!: "/",                  #  /some/request/and/http-params
            click!: [],                             # Click elements
            # focus!: [],                             # Set focus on element
            fill!: [],                              # fill focused field with content
            keys!: [],                         # send keystroke or key event
            js!: [],
            accept!: false,                           # Accept dialog or other js window
            dismiss!: false,                         # Dismiss dialog or other js window
            session!: false,                         # NO new session for each scene
            screenshot!: false,
            cookies_reset!: false,

            # browser!: @default_browser,
            # agent!: @default_user_agent,
            # wait_before!: @default_delay_secs,       # delay in seconds
            # wait_after!: @default_delay_secs,        # delay in seconds

            # After all sync tasks are done => perform expectations check
            title?: [],
            title_not?: [],
            text?: [], # List of ~r// matches expected in page text content
            text_not?: [],
            src?: [], # List of ~r// matches expected in page source code
            src_not?: [],
            frame?: [],                             # scene has content in these frames
            frame_not?: [],
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
            name?: [],                              # expect to find element name(s)
            name_not?: [],                              # expect to find element name(s)
            cookie?: [],                            # expect cookies
            cookie_not?: [],                            # expect cookies

            cookies?: true,                         # Enabled cookies?
            js?: true                               # Enabled javascript?


end
