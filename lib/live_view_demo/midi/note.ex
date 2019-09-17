defmodule LiveViewDemo.Midi.Note do
  @moduledoc """
  Represents a MIDI note.
  """
  @enforce_keys [:number, :velocity]
  defstruct [:number, :velocity]
end
