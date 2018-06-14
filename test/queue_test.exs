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
    q1 = new()
    q2 = push(<<0, 1, 2, 3, 4, 5, 6, 7, 8, 9>>, q1)
    assert len(q2) == 10
    assert is_empty(q2) == false
  end

  test "push two binary chunks" do
    q1 = new()
    q2 = push(<<0, 1, 2, 3, 4, 5, 6, 7, 8, 9>>, q1)
    q3 = push(<<10, 11, 12, 13, 14>>, q2)
    assert len(q3) == 15
    assert is_empty(q3) == false
  end

  test "pull shorter than first element length" do
    q1 = new()
    q2 = push(<<0, 1, 2, 3, 4, 5, 6, 7, 8, 9>>, q1)
    {data, q3} = pull(5, q2)
    assert len(q3) == 5
    assert data == <<0, 1, 2, 3, 4>>
  end

  test "pull equal as first element length" do
    q1 = new()
    q2 = push(<<0, 1, 2, 3, 4, 5, 6, 7, 8, 9>>, q1)
    {data, q3} = pull(10, q2)
    assert len(q3) == 0
    assert data == <<0, 1, 2, 3, 4, 5, 6, 7, 8, 9>>
  end

  test "pull larger as first element length without more data" do
    q1 = new()
    q2 = push(<<0, 1, 2, 3, 4, 5, 6, 7, 8, 9>>, q1)
    {data, q3} = pull(15, q2)
    assert len(q3) == 0
    assert is_empty(q3) == true
    assert data == <<0, 1, 2, 3, 4, 5, 6, 7, 8, 9>>
  end

  test "pull larger as first element length with extra data" do
    q1 = new()
    q2 = push(<<0, 1, 2, 3, 4, 5, 6, 7, 8, 9>>, q1)
    q3 = push(<<10, 11, 12, 13, 14>>, q2)
    {data, q4} = pull(12, q3)
    assert len(q4) == 3
    assert is_empty(q4) == false
    assert data == <<0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11>>
  end
end
