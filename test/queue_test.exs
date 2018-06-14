defmodule Binary.QueueTest do
  use ExUnit.Case
  doctest Binary.Queue

  import Binary.Queue

  test "create" do
    queue = new()
    assert len(queue) == 0
    assert is_empty(queue) == true
  end

  test "push a binary chunk" do
    q =
      new()
      |> push(<<0, 1, 2, 3, 4, 5, 6, 7, 8, 9>>)

    assert len(q) == 10
    assert is_empty(q) == false
  end

  test "push two binary chunks" do
    q =
      new()
      |> push(<<0, 1, 2, 3, 4, 5, 6, 7, 8, 9>>)
      |> push(<<10, 11, 12, 13, 14>>)

    assert len(q) == 15
    assert is_empty(q) == false
  end

  test "pull shorter than first element length" do
    q =
      new()
      |> push(<<0, 1, 2, 3, 4, 5, 6, 7, 8, 9>>)

    {data, q2} = pull(q, 5)
    assert len(q2) == 5
    assert data == <<0, 1, 2, 3, 4>>
  end

  test "pull equal as first element length" do
    q =
      new()
      |> push(<<0, 1, 2, 3, 4, 5, 6, 7, 8, 9>>)

    {data, q2} = pull(q, 10)
    assert len(q2) == 0
    assert data == <<0, 1, 2, 3, 4, 5, 6, 7, 8, 9>>
  end

  test "pull larger as first element length without more data" do
    q =
      new()
      |> push(<<0, 1, 2, 3, 4, 5, 6, 7, 8, 9>>)

    {data, q2} = pull(q, 15)
    assert len(q2) == 0
    assert is_empty(q2) == true
    assert data == <<0, 1, 2, 3, 4, 5, 6, 7, 8, 9>>
  end

  test "pull larger as first element length with extra data" do
    q =
      new()
      |> push(<<0, 1, 2, 3, 4, 5, 6, 7, 8, 9>>)
      |> push(<<10, 11, 12, 13, 14>>)

    {data, q2} = pull(q, 12)
    assert len(q2) == 3
    assert is_empty(q2) == false
    assert data == <<0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11>>
  end

  test "extensive test" do
    q =
      new()
      |> push(<<1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14>>)
      |> push(<<1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12>>)
      |> push(<<1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17>>)
      |> push(
        <<1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23>>
      )

    assert len(q) == 66

    {first_10, q_10} = pull(q, 10)
    assert byte_size(first_10) == 10
    assert len(q_10) == 56

    {second_10, q_20} = pull(q_10, 10)
    assert byte_size(second_10) == 10
    assert len(q_20) == 46

    {third_10, q_30} = pull(q_20, 10)
    assert byte_size(third_10) == 10
    assert len(q_30) == 36

    {fourth_10, q_40} = pull(q_30, 10)
    assert byte_size(fourth_10) == 10
    assert len(q_40) == 26

    {fifth_10, q_50} = pull(q_40, 10)
    assert byte_size(fifth_10) == 10
    assert len(q_50) == 16

    {sixth_10, q_60} = pull(q_50, 10)
    assert byte_size(sixth_10) == 10
    assert len(q_60) == 6

    {rest_6, q_66} = pull(q_60, 10)
    assert byte_size(rest_6) == 6
    assert len(q_66) == 0
    assert is_empty(q_66)
  end
end
