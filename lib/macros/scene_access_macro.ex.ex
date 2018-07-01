defmodule SceneAccessMacro do
    @moduledoc """
    SceneAccessMacro injects Access behaviour to Scene module
    """


    defmacro __using__(_opts) do
      quote do


        @behaviour Access


        @doc false
        def get keywords, key, default do
          res = Map.get keywords, key, []
          case res do
            {'EXIT', {:badarg, _}} -> default
            _ -> res
          end
        end


        @doc false
        def get_and_update list, key, fun do
          Map.get_and_update list, key, fun
        end


        @doc false
        def pop keywords, key do
          Map.pop keywords, key
        end


        @doc false
        def fetch keywords, key do
          res = Map.get keywords, key, []
          case res do
            {'EXIT', {:badarg, _}} -> :error
            _ -> {:ok, res}
          end
        end


      end
    end

end
