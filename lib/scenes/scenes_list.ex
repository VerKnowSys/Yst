defmodule ScenesList do

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
