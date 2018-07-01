defmodule Utils do
  @moduledoc """
  Utils module.
  """

  @doc """
  Returns seconds elapsed since 1970
  """
  def timestamp do
    :os.system_time :seconds
  end


  types = ~w[boolean number function nil integer binary bitstring list map float atom tuple pid port reference]

  for type <- types do

    def typeof(x) when unquote(:"is_#{type}")(x), do: unquote(type)

  end

end
