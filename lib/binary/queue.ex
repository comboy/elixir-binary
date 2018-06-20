defmodule Binary.Queue do
  @moduledoc """
  Queue for binary data.

  It resembles a pipeline: data is pushed on one end and pulled from the other.
  The order by which bytes are pushed in is the same by which they are pulled out.

  Internally, this queue implementation optimizes on the amount of copying of
  binary data in memory. Copying possibly occurs when binary data is pulled
  from the queue.

  ## Examples

    iex> Binary.Queue.new() |>  Binary.Queue.push(<<5, 208, 224, 23, 85>>)
    %Binary.Queue{data: {[<<5, 208, 224, 23, 85>>],[]}, size: 5}

    iex> Binary.Queue.new() |>  Binary.Queue.push(<<5, 208, 224, 23, 85>>) |> Binary.Queue.pull(4)
    {<<5, 208, 224, 23>> , %Binary.Queue{data: {[],["U"]}, size: 1}}

    iex> Binary.Queue.new() |>  Binary.Queue.push(<<5, 208, 224, 23, 85>>) |> Binary.Queue.push(<<82, 203>>)
    %Binary.Queue{data: {[<<82, 203>>],[<<5, 208, 224, 23, 85>>]}, size: 7}

  """

  @opaque t :: %__MODULE__{}
  defstruct size: 0, data: :queue.new()

  @doc """
  Returns a new empty binary queue.

  ## Examples

    iex> Binary.Queue.new()
    %Binary.Queue{data: {[],[]}, size: 0}
  """
  @spec new() :: t
  def new() do
    %__MODULE__{}
  end

  @doc """
  Push binary data on the queue. Returns a new queue containing the pushed binary data.

  ## Examples

    iex> Binary.Queue.push(Binary.Queue.new(), <<23, 75>>)
    %Binary.Queue{data: {[<<23, 75>>],[]}, size: 2}
  """
  @spec push(t, binary) :: t
  def push(queue, data) do
    %__MODULE__{size: queue.size + byte_size(data), data: :queue.in(data, queue.data)}
  end

  @doc """
  Pulls a single byte from the queue. Returns a tuple of the first byte and the new queue without that first byte.

  ## Examples

    iex> q = Binary.Queue.push(Binary.Queue.new(), <<23, 75>>)
    %Binary.Queue{data: {[<<23, 75>>],[]}, size: 2}
    iex> Binary.Queue.pull(q)
    {<<23>>, %Binary.Queue{data: {[], ["K"]}, size: 1}}
  """
  @spec pull(t) :: {binary, t}
  def pull(queue) do
    pull(queue, 1)
  end

  @doc """
  Pulls a number of bytes from the queue. Returns a tuple of the first byte and the new queue without that first byte.

  ## Examples

    iex> q = Binary.Queue.push(Binary.Queue.new(), <<23, 75, 17>>)
    %Binary.Queue{data: {[<<23, 75, 17>>],[]}, size: 3}
    iex> Binary.Queue.pull(q, 2)
    {<<23, 75>>, %Binary.Queue{data: {[], [<<17>>]}, size: 1}}
  """
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

  @doc """
  Returns the amount of bytes on the queue

  ## Examples

    iex> q = Binary.Queue.push(Binary.Queue.new(), <<23, 75, 17>>)
    %Binary.Queue{data: {[<<23, 75, 17>>],[]}, size: 3}
    iex> Binary.Queue.len(q)
    3
  """
  @spec len(%Binary.Queue{}) :: non_neg_integer
  def len(queue) do
    queue.size
  end

  @doc """
  Returns the amount of bytes on the queue

  ## Examples

    iex> q = Binary.Queue.new()
    %Binary.Queue{data: {[],[]}, size: 0}
    iex> Binary.Queue.is_empty(q)
    true
    iex> q = Binary.Queue.push(q, <<23, 75, 17>>)
    %Binary.Queue{data: {[<<23, 75, 17>>],[]}, size: 3}
    iex> Binary.Queue.is_empty(q)
    false
  """
  @spec is_empty(%Binary.Queue{}) :: boolean
  def is_empty(queue) do
    queue.size == 0 && :queue.is_empty(queue.data)
  end
end
