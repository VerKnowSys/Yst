defmodule CoreMacro do
  @moduledoc """
  CoreMacro injects Core functions used by Scenes and Scenarios
  """


  defmacro __using__(_opts) do
    quote do


      require Logger

      use Hound.Helpers

      use ScenarioPlayMacro
      use ExpectationsMacro
      use ActionMacro
      use ContentMacro


    end
  end

end
