defmodule LiveViewDemo.Midi.State do
  @moduledoc """
  Represents a MIDI message state.
  """
  @enforce_keys [:channels]
  defstruct channels: %{}
end
