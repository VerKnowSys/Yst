defmodule Option do
  require Logger

  @type t :: Option.t


  defmodule Some do
    @type t :: Some.t

    @enforce_keys [:v, :vtype]
    defstruct [:v, :vtype]

    def v(), do: None.v
    def v(nil), do: None.v
    def v(""), do: None.v
    def v(''), do: None.v
    def v(<<>>), do: None.v
    def v([]), do: None.v
    def v input do
      in_type = Util.typeof input
      Logger.debug "Type of key: #{input} => #{in_type}"
      %Some{
        v: input,
        vtype: in_type,
      }
    end

  end


  defmodule None do
    @type t :: None.t

    defstruct [:v, :vtype]

    def v do
      %None{}
    end
  end


end
