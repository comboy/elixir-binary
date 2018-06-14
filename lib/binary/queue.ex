defmodule Binary.Queue do
  @moduledoc """
  Queue binary data.

  This queue implementation optimizes on the copying of binary data in memory.
  Copying possibly occurs when binary data is taken out of the queue.
  """

  @type t :: %__MODULE__{size: non_neg_integer, data: :queue.t()}
  defstruct size: 0, data: :queue.new()

  @doc """
  Create a new binary queue.
  """
  @spec new() :: t
  def new() do
    %__MODULE__{}
  end

  @spec push(t, binary) :: t
  def push(queue, data) do
    %__MODULE__{size: queue.size + byte_size(data), data: :queue.in(data, queue.data)}
  end

  @spec pull(t) :: {binary, t}
  def pull(queue) do
    pull(queue, 1)
  end

  @spec pull(t, non_neg_integer) :: {binary, t}
  def pull(queue, amount) do
    pull(<<>>, amount, queue.size, queue.data)
  end

  defp pull(acc, 0, size, queue) do
    {acc, %__MODULE__{size: size, data: queue}}
  end

  defp pull(acc, _amount, 0, queue) do
    {acc, %__MODULE__{size: 0, data: queue}}
  end

  defp pull(acc, amount, size, queue) do
    {element, popped_queue} = :queue.out(queue)
    pull(acc, amount, size, popped_queue, element)
  end

  defp pull(acc, amount, _size, queue, :empty) do
    pull(acc, amount, 0, queue)
  end

  defp pull(acc, amount, size, queue, {:value, data}) when amount == byte_size(data) do
    pull(
      Binary.append(acc, data),
      0,
      :erlang.max(0, size - byte_size(data)),
      queue
    )
  end

  defp pull(acc, amount, size, queue, {:value, data}) when amount > byte_size(data) do
    data_size = byte_size(data)

    pull(
      Binary.append(acc, data),
      amount - data_size,
      :erlang.max(0, size - data_size),
      queue
    )
  end

  defp pull(acc, amount, size, queue, {:value, data}) when amount < byte_size(data) do
    {first, rest} = Binary.split_at(data, amount)

    pull(
      Binary.append(acc, first),
      0,
      :erlang.max(0, size - amount),
      :queue.in_r(rest, queue)
    )
  end

  @spec len(%Binary.Queue{}) :: non_neg_integer
  def len(queue) do
    queue.size
  end

  @spec is_empty(%Binary.Queue{}) :: boolean
  def is_empty(queue) do
    queue.size == 0 && :queue.is_empty(queue.data)
  end
end

## Implementation details

## Skip thinking of Enumerable/Collectable for now
## Configure chunk size
## Repack binaries according the chunk size
##   - when to do that: when taking out
