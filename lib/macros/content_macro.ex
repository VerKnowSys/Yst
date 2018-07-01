defmodule ContentMacro do
  @moduledoc """
  ScenarioPlayMacro injects play() function for Scenario
  """


  defmacro __using__(_opts) do
    quote do


      @doc """
      Defines base url of tested site
      """
      @spec url :: String.t
      def url, do: System.get_env "YS_URL"


      @doc """
      Defines username used on login panel
      """
      @spec user :: String.t
      def user, do: System.get_env "YS_LOGIN"


      @doc """
      Defines password used on login panel
      """
      @spec pass :: String.t
      def pass, do: System.get_env "YS_PASS"


      @doc ~S"""
      Performs match on given content. Accepted values are:
      "String" and ~/Regexp/

      ## Examples

          iex> "abc123 a123 AaBbCc123" |> Scenarios.content_matches?(~r/abc123/)
          true

          iex> "a123 AaBbCc123" |> Scenarios.content_matches?("AaBbCc")
          true

          iex> "a123 AaBbCc123" |> Scenarios.content_matches?("aAbBcC")
          false

          iex> "a123 AaBbCc123" |> Scenarios.content_matches?(~r/.*Cc\d+/)
          true

      """
      @spec content_matches?(contents :: list, matcher :: String.t | Regex.t) :: boolean
      def content_matches? contents, matcher do
        cond do
          # NOTE: String is a binary
          is_binary matcher ->
            String.contains? contents, matcher

          Regex.regex? matcher ->
            Regex.match? matcher, contents
        end
      end


    end
  end

end
