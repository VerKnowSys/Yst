
defmodule None do
  @moduledoc """
  Option None
  """
  @type t :: None.t

  defstruct [:v, :vtype]

  def v do
    %None{}
  end
end


defmodule Some do
  @moduledoc """
  Option Some
  """
  require Logger

  @type t :: Some.t

  @enforce_keys [:v, :vtype]
  defstruct [:v, :vtype]

  @spec v :: (Some.t | None.t)
  def v, do: None.v
  def v(nil), do: None.v
  def v(<<>>), do: None.v
  def v([]), do: None.v
  def v({}), do: None.v
  def v(%{}), do: None.v
  def v(%Some{}), do: None.v
  def v input do
    in_type = Utils.typeof input
    %Some{
      v: input,
      vtype: in_type,
    }
  end


  @spec unwrap(some :: Some.t) :: any
  def unwrap some do
    try do
      %Some{v: value} = some
      value
    rescue
      MatchError ->
        some

      _ ->
        some
    end
  end


  @spec unwrap_or_else(some :: Some.t, elseblock :: Some.t) :: any
  def unwrap_or_else some, elseblock do
    try do
      %Some{v: value} = some
      value
    rescue
      _ ->
        case elseblock do
          %Some{v: value, vtype: _} -> value
          val -> val
        end
    end
  end

end
