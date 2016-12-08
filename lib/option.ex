
defmodule None do
  @type t :: None.t

  defstruct [:v, :vtype]

  def v do
    %None{}
  end
end


defmodule Some do
  require Logger

  @type t :: Some.t

  @enforce_keys [:v, :vtype]
  defstruct [:v, :vtype]

  @spec v :: (Some.t | None.t)
  def v(), do: None.v
  def v(nil), do: None.v
  def v(<<>>), do: None.v
  def v([]), do: None.v
  def v({}), do: None.v
  def v(%{}), do: None.v
  def v(%Some{}), do: None.v
  def v input do
    in_type = Util.typeof input
    Logger.debug "Some: #{inspect input} of type: #{in_type}"
    %Some{
      v: input,
      vtype: in_type,
    }
  end


  @spec unwrap(some :: Some.t) :: any
  def unwrap some do
    try do
      %Some{v: value} = some
      Logger.debug "Unwrapped value: #{inspect value}"
      value
    rescue
      MatchError ->
        Logger.error "Failed to match Some-thing!"

      value ->
        Logger.error "caught #{value}"
    after
    end
  end


  @spec unwrap_or_else(some :: Some.t, elseblock :: any) :: any
  def unwrap_or_else some, elseblock do
    try do
      %Some{v: value} = some
      Logger.debug "Unwrapped value: #{inspect value}"
      value
    rescue
      any ->
        Logger.debug "Deliberately silenced error: #{inspect any}"
        elseblock
    after
    end
  end

end
