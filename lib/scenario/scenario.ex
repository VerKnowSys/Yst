defmodule Scenario do
  @moduledoc """
  Describes basic Scenario behaviour.

  Each tested Scenario-module has to implement
  "script" callback - that contains ordered list
  of Scenes to play by Director.

  """

  @doc """
  Defines script to be played by tested application
  """
  @callback script :: [Scene.t]


end



defmodule Scenarios do
  @moduledoc """
  Helper module as syntax sugar: Scenarios.play/1
  """
  use Core

  def script, do: []
end
