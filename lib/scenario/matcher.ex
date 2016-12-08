defmodule Scenario.Matcher do
  @moduledoc """
  Defines main matcher structure fields used to define callmap.
  """

  @type t :: Matcher.t
  @enforce_keys [:code]

  @default_delay_secs 0
  @default_user_agent Hound.Browser.user_agent :chrome_desktop
  @default_session :yst_phantomjs_session

  alias Option.{Some, None}


  defstruct code: (Some.v [200, 201, 202]),     # -200-202 => default success codes

            # content match
            text: [None.v], # List of ~r// matchers expected in page text content
            html: [None.v], # List of ~r// matchers expected in page source code

            has_id: [None.v],
            has_class: [None.v],
            has_tag: [None.v],

            delay_before_request: (Some.v @default_delay_secs),        # delay in seconds
            delay_after_request: (Some.v @default_delay_secs),         # delay in seconds

            # check element in other frame
            in_frame: [None.v],

            # Browser session name to be used.
            with_agent: (Some.v @default_user_agent),

            # By default each scenario is executed in separate session
            with_session: [Some.v @default_session]

            # TODO: Css matchers (?)

            # TODO: Wildcards (?)

end
