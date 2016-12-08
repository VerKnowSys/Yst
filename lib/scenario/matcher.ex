defmodule Scenario.Matcher do
  @moduledoc """
  Defines main matcher structure fields used to define callmap.
  """

  @type t :: Matcher.t
  @enforce_keys [:code]

  @default_delay_secs 0
  @default_user_agent Hound.Browser.user_agent :chrome_desktop
  @default_session :yst_phantomjs_session

  defstruct code: (Option.some [200, 201, 202]),     # -200-202 => default success codes

            # content match
            text: [Option.none], # List of ~r// matchers expected in page text content
            html: [Option.none], # List of ~r// matchers expected in page source code

            has_id: [Option.none],
            has_class: [Option.none],
            has_tag: [Option.none],

            delay_before_request: (Option.some @default_delay_secs),        # delay in seconds
            delay_after_request: (Option.some @default_delay_secs),         # delay in seconds

            # check element in other frame
            in_frame: [Option.none],

            # Browser session name to be used.
            with_agent: (Option.some @default_user_agent),

            # By default each scenario is executed in separate session
            with_session: [Option.some @default_session]

            # TODO: Css matchers (?)

            # TODO: Wildcards (?)

end
