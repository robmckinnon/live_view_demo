defmodule LiveViewDemo.Midi.State do
  @moduledoc """
  Represents a MIDI message state.
  """
  @enforce_keys [:channels, :user_gesture]
  defstruct channels: %{}, user_gesture: false
end
