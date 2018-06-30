defmodule CoreTest do
  use ExUnit.Case

  require Logger

  require Utils


  test "Option should work correctly with some types" do
    assert Some.v() == %None{}
    assert Some.v([]) == %None{}
    assert Some.v({}) == %None{}
    assert Some.v(%{}) == %None{}
    assert Some.v(%None{}) == %None{}
    assert Some.v("") == %None{}
    assert Some.v('') == %None{}
    assert Some.v(<<>>) == %None{}
    assert Some.v(nil) == %None{}
    assert Some.v(%Some{v: nil, vtype: nil}) == %None{}
    assert Some.v(Some.unwrap %Some{v: 123, vtype: "number"}) == %Some{v: 123, vtype: "number"}
    assert Some.v(2) == %Some{v: 2, vtype: "number"}
    assert Some.v("123") == %Some{v: "123", vtype: "binary"}
    assert Some.v('123') == %Some{v: '123', vtype: "list"}
  end


  test "Option should correctly unwrap" do
    value = Some.v Keyword.new [some: "more", time: "for"]
    assert value == %Some{v: [some: "more", time: "for"], vtype: "list"}
    assert Some.unwrap Some.v() == %None{}
    assert Some.unwrap Some.v(12345) == 12345

    value_wrong = [even: "now"]
    assert 1 == value_wrong |> (Some.unwrap_or_else 1)
    assert 3 == {:anything, :else} |> (Some.unwrap_or_else 3)
    assert {:anything, :else} == (Some.v {:anything, :else}) |> (Some.unwrap_or_else 3)
    assert [some: "more", time: "for"] == value |> Some.unwrap()
    assert [some: "more", time: "for"] == value |> (Some.unwrap_or_else :NOWAI)
  end


end
