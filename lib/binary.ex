defmodule Binary do
  @moduledoc """
  Functions to operate on binaries.

  Wrappers of erlang's `:binary`, functions that try to mimic `String` behaviour
  but on bytes, and some very simple functions that are here just to make
  piping operations on binaries easier.
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
  Split binary into list of binaries based on `pattern`.

  `pattern` can be a binary, or a byte.

  It mimics erlang's `:binary.split/3`split behavior rather than `String.split/3`, and only
  splits once by default.

  `global: true` option can be provided to split on all occurences.

      iex> <<1, 2, 3, 2, 3>> |> Binary.split(<<3, 2>>)
      [<<1, 2>>, <<3>>]
      iex> <<1, 2, 3, 2, 3>> |> Binary.split(2)
      [<<1>>, <<3, 2, 3>>]
      iex> <<1, 2, 3, 2, 3>> |> Binary.split(2, global: true)
      [<<1>>, <<3>>, <<3>>]
  """
  # TODO maybe add parts: option, but I don't think it's practical for binaries
  @spec split(binary, binary | byte, Keyword.t) :: list(binary)
  def split(binary, pattern, opts \\ [])

  def split(binary, byte, opts) when is_binary(binary) and is_integer(byte) and byte >= 0 and byte < 256 do
    split(binary, <<byte>>, opts)
  end

  def split(binary, pattern, opts) do
    global = opts |> Keyword.get(:global, false)
    :binary.split(binary, pattern, global && [:global] || [])
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

  @doc """
  Replace binary pattern inside the binary with the replacement.

  For readability examples are presented on strings, but do note we are operating on bytes, not codepoints.

      iex> "a-b-c" |> Binary.replace("-", "..")
      "a..b..c"

  By default it replaces all occurrences. If you only want to replace the first occurence,

      iex> "a-b-c" |> Binary.replace("-", "..", global: false)
      "a..b-c"
  """
  @spec replace(binary, binary, binary, Keyword.t) :: binary
  def replace(binary, pattern, replacement, opts \\ []) when is_binary(binary) and is_binary(pattern) and is_binary(replacement) do
    # We default to global replacement following Elixir.String as opposed to erlang :binary.replace
    erl_opts = case opts[:global] do
      false -> []
          _ -> [:global]
    end
    :binary.replace(binary, pattern, replacement, erl_opts)
  end

  @doc """
  Returns the length of the longest common prefix in the provided list of binaries.

  Uses `:binary.longest_common_prefix/1`

      iex> ["moo", "monad", "mojo"] |> Binary.longest_common_prefix
      2
  """
  @spec longest_common_prefix([binary]) :: non_neg_integer
  def longest_common_prefix(binaries) when is_list(binaries) do
    :binary.longest_common_prefix(binaries)
  end

  @doc """
  Returns the length of the longest common prefix in the provided list of binaries

  Uses `:binary.longest_common_suffix/1`
  """
  @spec longest_common_suffix([binary]) :: non_neg_integer
  def longest_common_suffix(binaries) when is_list(binaries) do
    :binary.longest_common_suffix(binaries)
  end

  @doc """
  Exctracts part of the binarty starting at given position with given length.

  Based on `Kernel.binary_part/3`, but:

  * it also accepts negative position, interpreting it as position relative to the end of the binary.
  * length is allowed to be outside binary size i.e. it is max number of fetched bytes

  ## Examples

      iex> x = <<1, 2, 3, 4, 5>>
      <<1, 2, 3, 4, 5>>
      iex> x |> Binary.part(1, 2)
      <<2, 3>>
      iex> x |> Binary.part(-2, 1)
      <<4>>
      iex> x |> Binary.part(-2, -1)
      <<3>>
      iex> x |> Binary.part(-1, 10)
      <<5>>

  """
  def part(binary, position, len)

  # Allow negative position
  def part(binary, position, len) when is_binary(binary) and is_integer(position) and is_integer(len) and position < 0 do
    part(binary, byte_size(binary) + position, len)
  end

  # length goes outside the binary, which would raise ArgumentError in Kernel.binary_part/3
  def part(binary, position, len) when is_binary(binary) and is_integer(position) and is_integer(len) and (position + len > byte_size(binary)) do
    part(binary, position, byte_size(binary) - position)
  end

  # length is negative and goes outside binary
  def part(binary, position, len) when is_binary(binary) and is_integer(position) and is_integer(len) and len < 0 and (position + len < 0) do
    part(binary, position, -1 * position)
  end

  def part(binary, position, len) when is_binary(binary) and is_integer(position) and is_integer(len) do
    Kernel.binary_part(binary, position, len)
  end

  @doc """
  Interpret binary as an unsigned integer representation. Second option decides endianness which defaults to `:big`.

  Uses `:binary.decode_unsigned/1`

  ## Examples

      iex> <<1, 2>> |> Binary.to_integer
      258
      iex> <<1, 2>> |> Binary.to_integer(:little)
      513

  """
  @spec to_integer(binary, :big | :little) :: non_neg_integer
  def to_integer(binary, endianness \\ :big) when is_binary(binary) do
    :binary.decode_unsigned(binary, endianness)
  end

  @doc """
  Returns binary representation of the provided integer. Second option decides endianness which defaults to `:big`.

  Uses `:binary.encode_unsigned/1`

  ## Examples

      iex> 1234 |> Binary.from_integer
      <<4, 210>>
      iex> 1234 |> Binary.from_integer(:little)
      <<210, 4>>

  """
  @spec from_integer(non_neg_integer, :big | :little) :: binary
  def from_integer(int, endianness \\ :big) when is_integer(int) and int >= 0 do
    :binary.encode_unsigned(int, endianness)
  end

  @doc """
  Returns hex representation of the provided binary.

      iex> <<190,239>> |> Binary.to_hex
      "beef"

  Just a shorthand for:

      Base.encode16(binary, case: :lower)
  """
  @spec to_hex(binary) :: binary
  def to_hex(binary) when is_binary(binary) do
    binary |> Base.encode16(case: :lower)
  end

  @doc """
  Returns binary from the hex representation.

      iex> "ff01" |> Binary.from_hex
      <<255, 1>>

  Just a shorthand for:

      Base.decode16!(binary, case: :mixed)
  """
  @spec from_hex(binary) :: binary
  # Before API is frozen, maybe it should return {:ok, and have a bang version.
  # Although if somebody cares about that, she can use Base.decode16 and this is meant to be short.
  def from_hex(binary) when is_binary(binary) do
    binary |> Base.decode16!(case: :mixed)
  end

  @doc """
  Takes the first N bytes from the binary.

  When negative count is given, last N bytes are returned. In case when
  count > byte_size, it will return the full binary.
  """
  @spec take(binary, integer) :: binary
  def take(binary, count)

  def take(binary, count) when is_binary(binary) and is_integer(count) and count < 0 do
    binary |> split_at(count) |> elem(1)
  end

  def take(binary, count) when is_binary(binary) and is_integer(count) and count >= 0 do
    binary |> split_at(count) |> elem(0)
  end

  @doc """
  Drops first N bytes from the binary.

  If provided count is negative, it drops N bytes from the end.
  In case where count > byte_size, it will return `<<>>`
  """
  @spec drop(binary, integer) :: binary
  def drop(binary, count)

  def drop(binary, count) when is_binary(binary) and is_integer(count) and count < 0 do
    binary |> split_at(count) |> elem(0)
  end

  def drop(binary, count) when is_binary(binary) and is_integer(count) and count >= 0 do
    binary |> split_at(count) |> elem(1)
  end

  @doc """
  Append binary or a byte to another binary.

  Handy for pipping. With binary argument it's exactly the same as `Kernel.<>/2`
  """
  @spec append(binary, binary | byte) :: binary
  def append(left, right)

  def append(left, right) when is_binary(left) and is_integer(right) and right >= 0 and right < 256 do
    left <> <<right>>
  end

  def append(left, right) when is_binary(left) and is_binary(right) do
    left <> right
  end

  @doc """
  Prepend binary or a byte to another binary.
  """
  @spec prepend(binary, binary | byte) :: binary
  def prepend(left, right)

  def prepend(left, right) when is_binary(left) and is_integer(right) and right >= 0 and right < 256 do
    <<right>> <> left
  end

  def prepend(left, right) when is_binary(left) and is_binary(right) do
    right <> left
  end

end
