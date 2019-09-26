defmodule LiveViewDemo.Midi.State do
  @moduledoc """
  Represents a MIDI message state.
  """
  @enforce_keys [:channels, :inputs, :outputs, :user_gesture]
  defstruct channels: %{}, inputs: %{}, outputs: %{}, user_gesture: false, bpm: 120
end
