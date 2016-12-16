defmodule ScenesList do

  def scripts do
    BasicLoginLogoutScene.script ++
    HeadlessScene.script
  end

end
