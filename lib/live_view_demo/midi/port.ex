defmodule LiveViewDemo.Midi.Port do
  @moduledoc """
  Represents a MIDI input or output port.

  See: http://webaudio.github.io/web-midi-api/#midiport-interface
  """
  @enforce_keys [:id, :manufacturer, :name, :type, :version, :state, :connection]
  defstruct [:id, :manufacturer, :name, :type, :version, :state, :connection]
end
