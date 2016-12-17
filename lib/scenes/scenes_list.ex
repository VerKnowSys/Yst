defmodule ScenesList do
  @moduledoc """
  This is core module that defines list of scripts of scenes
  that will be used by default by Yst.

  All scenes modules are defined under lib/scenes/*.ex
  """

  @doc ~S"""
  Defines scripts - collection of all scripts defined.

  ## Examples

      iex> ScenesList.scripts |> (Enum.filter fn k -> String.contains? k[:name], "cookies-reset" end) != []
      true

      iex> ScenesList.scripts |> Enum.count >= 5
      true

      iex> ScenesList.scripts == []
      false

  """
  def scripts do
    BasicLoginLogoutScene.script ++
    HeadlessScene.script
  end

end
