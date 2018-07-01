defmodule TransactMacro do
  @moduledoc """
  TransactMacro module defines transact/1 macro.
  """


  defmacro __using__(_opts) do
    quote do
      import  Amnesia, only: [defdatabase: 2]
      require Amnesia
      require Amnesia.Fragment
      require Amnesia.Helper

      use Amnesia

      import TransactMacro

      alias Model.RecordedScenario
    end
  end


  @doc """
  transact macro is a simple wrapper around Amnesia.transaction block
  """
  defmacro transact block do
    quote do
      Amnesia.transaction do
        use Amnesia

        alias Model.RecordedScenario
        use RecordedScenario

        unquote block
      end
    end
  end

end
