defmodule Util do

  types = ~w[boolean number function nil integer binary bitstring list map float atom tuple pid port reference]

  for type <- types do

    def typeof(x) when unquote(:"is_#{type}")(x), do: unquote(type)

  end
end
