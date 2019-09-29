defmodule LiveViewDemo.Midi do
  @moduledoc """
  The MIDI context.

  Summary of MIDI Messages:
  https://www.midi.org/specifications-old/item/table-1-summary-of-midi-message
  """

  alias LiveViewDemo.Midi.{MessageHandler, Port, State}

  defdelegate handle_message(type, key, value, channel, port_id, time, state),
    to: MessageHandler

  defdelegate handle_message(type, number, channel, port_id, time, state),
    to: MessageHandler

  def user_gesture(%State{user_gesture: false} = state) do
    %{state | user_gesture: true}
  end

  def midi_port(%{
        "id" => id,
        "manufacturer" => manufacturer,
        "name" => name,
        "type" => type,
        "version" => version,
        "state" => state,
        "connection" => connection
      }) do
    %Port{
      id: id,
      manufacturer: manufacturer,
      name: name,
      type: type,
      version: version,
      state: state,
      connection: connection
    }
  end

  def midi_input(%{"id" => id} = input, %State{} = state) when is_map(input) do
    port = midi_port(input)
    inputs = state.inputs |> Map.put(id, port)
    %{state | inputs: inputs}
  end

  def midi_output(%{"id" => id} = output, %State{} = state) when is_map(output) do
    port = midi_port(output)
    outputs = state.outputs |> Map.put(id, port)
    %{state | outputs: outputs}
  end

  def inc_tempo(state) do
    state = put_in(state.bpm, min(240, state.bpm + 1))
    put_in(state.ms_per_beat, 60000 / state.bpm)
  end

  def dec_tempo(state) do
    state = put_in(state.bpm, max(1, state.bpm - 1))
    put_in(state.ms_per_beat, 60000 / state.bpm)
  end
end
