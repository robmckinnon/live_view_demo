defmodule LiveViewDemo.Midi.Quantise do
  @moduledoc false

  @doc """
  ## Examples

    iex> alias LiveViewDemo.Midi.Quantise
    ...> Quantise.start_end_beats(0, 5, 125)
    [{0, 0}, {125, 1}]

    iex> Quantise.start_end_beats(876, 5, 125)
    [{875, 7}, {1000, 8}]

    iex> Quantise.start_end_beats(939, 5, 125)
    [{875, 7}, {1000, 8}]

    iex> Quantise.start_end_beats(0, 876, 125)
    [{0, 0}, {875, 7}]

    iex> Quantise.start_end_beats(876, 939, 125)
    [{875, 7}, {1875, 15}]

  """
  def start_end_beats(time, duration, quantum) do
    start = quantise_to_nearest(time, quantum)
    finish = quantise_to_nearest(time + duration, quantum)

    start_beat = if start == finish, do: quantise_number_under(time, quantum), else: start

    finish_beat =
      if finish == start, do: quantise_number_over(time + duration, quantum), else: finish

    [{start_beat, div(start_beat, quantum)}, {finish_beat, div(finish_beat, quantum)}]
  end

  @doc """
  ## Examples

    iex> LiveViewDemo.Midi.Quantise.quantise_to_nearest(876, 125)
    875

    iex> LiveViewDemo.Midi.Quantise.quantise_to_nearest(939, 125)
    1000
  """
  def quantise_to_nearest(val, quantum) when is_integer(val) and is_integer(quantum) do
    under = quantise_number_under(val, quantum)
    over = quantise_number_over(val, quantum)
    under_closer = abs(val - under) < abs(val - over)

    if under_closer do
      under
    else
      over
    end
  end

  @doc """
  ## Example

    iex> LiveViewDemo.Midi.Quantise.quantise_number_over(7, 5)
    10
  """
  def quantise_number_over(val, quantum) when is_integer(val) and is_integer(quantum) do
    remainder = rem(val, quantum)
    sign = if val >= 0, do: 1, else: -1
    mod = if remainder != 0, do: quantum, else: 0
    val - remainder + sign * mod
  end

  @doc """
  ## Example

    iex> LiveViewDemo.Midi.Quantise.quantise_number_under(7, 5)
    5
  """
  def quantise_number_under(val, quantum) when is_integer(val) and is_integer(quantum) do
    remainder = rem(val, quantum)
    val - remainder
  end
end
