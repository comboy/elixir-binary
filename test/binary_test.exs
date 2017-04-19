defmodule BinaryTest do
  use ExUnit.Case
  doctest Binary

  import Binary

  test "to_list" do
    assert to_list(<<>>) == []
    assert to_list(<<1, 2>>) == [1,2]
    assert to_list("moo") == 'moo'
  end

  test "From_list" do
    assert from_list([]) == <<>>
    assert from_list([3, 1, 7]) == <<3, 1, 7>>
    assert_raise(ArgumentError, fn ->
     from_list([1234, 4])
    end)
  end

  test "First" do
    assert first(<<97, 98>>) == 97
    assert first(<<1>>) == 1
    assert_raise(ArgumentError, fn ->
      first(<<>>)
    end)
  end

  test "last" do
    assert last("bender is great") == 116
    assert last(<<1>>) == 1
    assert_raise(ArgumentError, fn ->
      last(<<>>)
    end)
  end

  test "copy" do
    assert copy(<<3, 7>>, 3) == <<3, 7, 3, 7, 3, 7>>
    assert copy(<<1, 2, 3>>, 1) == <<1, 2, 3>>
    assert copy(<<>>, 10) == <<>>
    assert copy(<<1>>, 0) == <<>>
    assert_raise(ArgumentError, fn ->
      copy("boo", -1)
    end)
  end
end
