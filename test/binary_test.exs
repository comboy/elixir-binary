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

  test "reverse" do
    assert reverse(<<>>) == <<>>
    assert reverse(<<1, 2, 3>>) == <<3, 2, 1>>
    assert reverse(<<1>>) == <<1>>
  end

  test "at" do
    assert <<1, 2, 3>> |> at(0) == 1
    assert <<1, 2, 3>> |> at(2) == 3
    assert <<1, 2, 3>> |> at(4) == nil
    assert        <<>> |> at(0) == nil
    assert       <<1>> |> at(-1) == 1
    assert <<1, 2, 3>> |> at(-1) == 3
    assert <<1, 2, 3>> |> at(-2) == 2
    assert <<1, 2, 3>> |> at(-3) == 1
    assert <<1, 2, 3>> |> at(-4) == nil
  end

  test "split" do
    x = <<1, 2, 3, 2, 4, 5, 3>>
    assert x |> split(<<2>>) == [<<1>>, <<3, 2, 4, 5, 3>>]
    assert x |> split(2) == [<<1>>, <<3, 2, 4, 5, 3>>]
    assert x |> split(<<2>>, global: true) == [<<1>>, <<3>>, <<4, 5, 3>>]
    assert x |> split(2, global: true) == [<<1>>, <<3>>, <<4, 5, 3>>]
    assert x |> split("foo") == [x]
    assert x |> split(123) == [x]
    assert x |> split(3, global: true) == [<<1, 2>>, <<2, 4, 5>>, <<>>]
    assert x |> split(<<2, 3, 2>>) == [<<1>>, <<4, 5, 3>>]
    assert <<>> |> split(<<3>>) == [<<>>]
    assert <<1, 0>> |> split(0) == [<<1>>, <<>>]
  end

  test "split_at" do
    assert <<1, 2, 3>> |> split_at(1) == {<<1>>, <<2, 3>>}
    assert <<1, 2, 3>> |> split_at(0) == {<<>>, <<1, 2, 3>>}
    assert <<1, 2, 3>> |> split_at(3) == {<<1, 2, 3>>, <<>>}
    assert <<1, 2, 3>> |> split_at(-1) == {<<1, 2>>, <<3>>}
  end

  test "trim_trailing" do
    assert <<1, 2, 0, 0, 0>> |> trim_trailing == <<1, 2>>
    assert <<1, 2, 0, 0, 0>> |> trim_trailing(0) == <<1, 2>>
    assert <<1, 2, 0, 0, 0>> |> trim_trailing(1) == <<1, 2, 0, 0, 0>>
    assert <<7, 7, 1, 2, 7>> |> trim_trailing(7) == <<7, 7, 1, 2>>
    assert <<>> |> trim_trailing(7) == <<>>
  end

  test "pad_trailing" do
    assert <<1>> |> pad_trailing(3) == <<1, 0, 0>>
    assert <<1, 2>> |> pad_trailing(3, 7) == <<1, 2, 7>>
    assert <<1, 2, 3>> |> pad_trailing(3, 7) == <<1, 2, 3>>
    assert <<1, 2, 3>> |> pad_trailing(2, 7) == <<1, 2, 3>>
    assert <<>> |> pad_trailing(2) == <<0, 0>>
  end

  test "trim_lleading" do
    assert <<0, 1, 0, 0>> |> trim_leading == <<1, 0, 0>>
    assert <<>> |> trim_leading == <<>>
    assert <<1, 1, 2>> |> trim_leading(1) == <<2>>
  end

  test "pad leading" do
    assert <<1, 2>> |> pad_leading(4) == <<0, 0, 1, 2>>
    assert <<1, 2>> |> pad_leading(1) == <<1, 2>>
    assert <<>> |> pad_leading(1) == <<0>>
  end

  test "replace" do
    assert "hoothoot" |> replace("oo","a") == "hathat"
    assert "hoothoot" |> replace("oo","a", global: false) == "hathoot"
  end

  test "longest_common_prefix" do
    assert ["foo fighters", "foofoo"] |> longest_common_prefix == 3
  end

  test "longest_common_suffix" do
    assert ["foo", "mooooo", "boo"] |> longest_common_suffix == 2
  end

  test "part" do
     x = <<1, 2, 3, 4, 5>>
     assert x |> part(1, 2) == <<2, 3>>
     assert x |> part(-2, 1) == <<4>>
     assert x |> part(-2, -1) == <<3>>
     assert x |> part(-2, -3) == <<1, 2, 3>>
     assert x |> part(3, 10) == <<4, 5>>
     assert x |> part(3, -2) == <<2, 3>>
     assert x |> part(3, -3) == <<1, 2, 3>>
     assert x |> part(3, -4) == <<1, 2, 3>>
  end

  test "to_integer" do
    assert <<17>> |> to_integer == 17
    assert <<4, 210>> |> to_integer == 1234
    assert <<210, 4>> |> to_integer(:little) == 1234
  end

  test "from_integer" do
    assert 0 |> from_integer == <<0>>
    assert 258 |> from_integer == <<1, 2>>
    assert 258 |> from_integer(:little) == <<2, 1>>
  end

  test "to_hex" do
    assert <<>> |> to_hex == ""
    assert <<1>> |> to_hex == "01"
    assert <<255, 1>> |> to_hex == "ff01"
  end

  test "from_hex" do
    assert "BEEF" |> from_hex == <<190, 239>>
    assert "beef" |> from_hex == <<190, 239>>
    assert "bEEf" |> from_hex == <<190, 239>>
    assert "" |> from_hex == <<>>
  end

  test "take" do
    assert <<>>  |> take(1) == <<>>
    assert <<1>> |> take(0) == <<>>
    assert <<1, 2, 3, 4>> |> take(1) == <<1>>
    assert <<1, 2, 3, 4>> |> take(2) == <<1, 2>>
    assert <<1, 2, 3, 4>> |> take(5) == <<1, 2, 3, 4>>
    assert <<1, 2, 3, 4>> |> take(-1) == <<4>>
    assert <<1, 2, 3, 4>> |> take(-3) == <<2, 3, 4>>
    assert <<1, 2, 3, 4>> |> take(-13) == <<1, 2, 3, 4>>
    assert "Dave Brubeck" |> take(5) == "Dave "
  end

  test "drop" do
    assert <<>>  |> drop(1) == <<>>
    assert <<1>> |> drop(0) == <<1>>
    assert <<1, 2, 3, 4>> |> drop(1) == <<2, 3, 4>>
    assert <<1, 2, 3, 4>> |> drop(2) == <<3, 4>>
    assert <<1, 2, 3, 4>> |> drop(5) == <<>>
    assert <<1, 2, 3, 4>> |> drop(-1) == <<1, 2, 3>>
    assert <<1, 2, 3, 4>> |> drop(-3) == <<1>>
    assert <<1, 2, 3, 4>> |> drop(-13) == <<>>
  end

  test "append" do
    assert <<2, 3>> |> Binary.append(<<4>>) == <<2, 3, 4>>
    assert <<2, 3>> |> Binary.append(4) == <<2, 3, 4>>
    assert <<>> |> Binary.append(0) == <<0>>
  end

  test "prepend" do
    assert <<2, 3>> |> Binary.prepend(<<1>>) == <<1, 2, 3>>
    assert <<2, 3>> |> Binary.prepend(1) == <<1, 2, 3>>
    assert <<>> |> Binary.prepend(0) == <<0>>
  end
end
