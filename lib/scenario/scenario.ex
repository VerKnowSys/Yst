defmodule Scenario do
  @moduledoc """
  Scenario module describes basic logic over user "scenes-script"
  """
  use Behaviour


  @doc """
  Defines script to be played by tested application
  """
  defcallback script :: [Scene.t]


end



defmodule Scenarios do
  @moduledoc """
  Helper module as syntax sugar: Scenarios.play/1
  """
  use Core

  def script, do: []
end
