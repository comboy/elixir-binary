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
  @spec copy(binary, number) :: binary
  def copy(bin, n) when is_binary(bin) and is_number(n) do
    :binary.copy(bin, n)
  end

end
