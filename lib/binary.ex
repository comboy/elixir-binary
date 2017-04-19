defmodule Binary do
  @moduledoc """
  Functions to operate on binaries.
  """

  @doc """
  Convert list of bytes into binary.
  """
  @spec from_list(list) :: binary
  def from_list(list) when is_list(list) do
    :binary.list_to_bin(list)
  end

  @doc """
  Converts binary to a list of bytes.
  """
  @spec to_list(binary) :: list
  def to_list(bin) when is_binary(bin) do
    :binary.bin_to_list(bin)
  end

  @doc """
  Returns the first byte of the binary as an integer.
  """
  @spec first(binary) :: byte
  def first(bin) when is_binary(bin) do
    :binary.first(bin)
  end

  @doc """
  Returns the last byte of the binary as an integer.
  """
  @spec last(binary) :: byte
  def last(bin) when is_binary(bin) do
    :binary.last(bin)
  end

  @doc """
  Create a binary with the binary content repeated n times.
  """
  @spec copy(binary, non_neg_integer) :: binary
  def copy(bin, n) when is_binary(bin) and is_integer(n) do
    :binary.copy(bin, n)
  end

  @doc """
  Reverse bytes order in the binary.
  """
  @spec reverse(binary) :: binary
  def reverse(binary) when is_binary(binary), do: do_reverse(binary, <<>>)

  # Would be nice to bench this against to_list |> Enum.reverse |> from_list
  # I only assumed that this version should be faster
  defp do_reverse(<<>>, acc), do: acc
  defp do_reverse(<< x :: binary-size(1), bin :: binary >>, acc), do: do_reverse(bin, x <> acc)

  @doc """
  Returns byte at given position. Numbering starts with `0`.

  Position can be negative to make it relative to the end of the binary.

  Returns `nil` if position is outside the binary (following `Enum` and `String` behavior)

  ## Examples

      iex> <<1, 2, 3>> |> Binary.at(1)
      2
      iex> <<1, 2, 3>> |> Binary.at(3)
      nil
      iex> <<1, 2, 3>> |> Binary.at(-1)
      3

  """
  @spec at(binary, integer) :: byte
  def at(binary, postion)

  def at(binary, position) when is_binary(binary) and is_integer(position) and (position >= byte_size(binary) or position < -1*byte_size(binary)), do: nil

  def at(binary, position) when is_integer(position) and position < 0 do
    binary |> at(byte_size(binary) + position)
  end

  def at(binary, position) when is_integer(position) do
    :binary.at(binary, position)
  end

  @doc """
  Splits a binary into two at the specified position. Returns a tuple.

  When position is negative it's counted from the end of the binary.

  ## Examples

      iex> <<1, 2, 3>> |> Binary.split_at(1)
      {<<1>>, <<2, 3>>}
      iex> <<1, 2, 3, 4>> |> Binary.split_at(-1)
      {<<1, 2, 3>>, <<4>>}
      iex> <<1, 2, 3>> |> Binary.split_at(10)
      {<<1, 2, 3>>, <<>>}
  """
  @spec split_at(binary, integer) :: byte
  def split_at(binary, position)

  def split_at(binary, position) when is_binary(binary) and is_integer(position) and position >= byte_size(binary), do: { binary, <<>> }
  def split_at(binary, position) when is_binary(binary) and is_integer(position) and position < -1*byte_size(binary), do: { <<>>, binary }

  def split_at(binary, position) when is_binary(binary) and is_integer(position) and position < 0 do
    split_at(binary, byte_size(binary) + position)
  end

  def split_at(binary, position) when is_binary(binary) and is_integer(position) do
    { Kernel.binary_part(binary, 0, position),
      Kernel.binary_part(binary, position, byte_size(binary) - position) }
  end

  @doc """
  Removes all specified trailing bytes from the the binary.

  ## Examples

      iex> <<0, 1, 2, 0, 0>> |> Binary.trim_trailing
      <<0, 1, 2>>
      iex> <<1, 2>> |> Binary.trim_trailing(2)
      <<1>>
  """
  @spec trim_trailing(binary, byte) :: binary
  # Maybe also provide an option to pass binary instead of byte.
  def trim_trailing(binary, byte \\ 0) when is_binary(binary) and is_integer(byte) do
    do_trim_trailing(binary |> reverse, byte)
  end

  defp do_trim_trailing(<< byte, binary :: binary >>, byte), do: do_trim_trailing(binary, byte)
  defp do_trim_trailing(<< binary :: binary >>, _byte), do: binary |> reverse

  @doc """
  Pad end of the binary with the provided byte until provided length is achieved.

  ## Examples

      iex> <<3, 7>> |> Binary.pad_trailing(5)
      <<3, 7, 0, 0, 0>>

  """
  @spec pad_trailing(binary, non_neg_integer, byte) :: binary
  def pad_trailing(binary, len, byte \\ 0)

  # Return binary if it's already long enough
  def pad_trailing(binary, len, byte) when is_binary(binary) and is_integer(len) and is_integer(byte) and len > 0
                                           and byte_size(binary) >= len, do: binary
  def pad_trailing(binary, len, byte) when is_binary(binary) and is_integer(len) and is_integer(byte) and len > 0 do
    binary <> (<< byte >> |> copy(len - byte_size(binary)))
  end

  @doc """
  Removes all spcefied leading bytes from the binary.
  """
  @spec trim_leading(binary, byte) :: binary
  def trim_leading(binary, byte \\ 0)

  def trim_leading(<< byte, binary :: binary >>, byte) when is_binary(binary) and is_integer(byte), do: trim_leading(binary, byte)
  def trim_leading(binary, byte) when is_binary(binary) and is_integer(byte), do: binary

  @doc """
  Pad with the provided byte at the beginning of the binary until provided length is achieved.
  """
  @spec pad_leading(binary, non_neg_integer, byte) :: binary
  def pad_leading(binary, len, byte \\ 0)

  # Return binary if it's already long enough
  def pad_leading(binary, len, byte) when is_binary(binary) and is_integer(len) and is_integer(byte) and len > 0
                                           and byte_size(binary) >= len, do: binary
  def pad_leading(binary, len, byte) when is_binary(binary) and is_integer(len) and is_integer(byte) and len > 0 do
    (<< byte >> |> copy(len - byte_size(binary))) <> binary
  end


end
