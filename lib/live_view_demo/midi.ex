defmodule LiveViewDemo.Midi do
  @moduledoc """
  The MIDI context.

  Summary of MIDI Messages:
  https://www.midi.org/specifications-old/item/table-1-summary-of-midi-message
  """

  alias LiveViewDemo.Midi.{Note, Port, State}

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

  @doc """
  Add note to events and notes.
  """
  def note_on(time, number, velocity, %{events: events, notes_on: notes_on})
      when is_integer(number) and is_integer(velocity) and
             is_map(notes_on) and is_list(events) do
    note = %Note{number: number, velocity: velocity}
    notes_on = notes_on |> Map.put(number, note)
    %{events: [{time, note} | events], notes_on: notes_on}
  end

  @doc """
  Add note off to events and remove from notes.
  """
  def note_off(time, number, %{events: events, notes_on: notes_on})
      when is_integer(number) and is_map(notes_on) and is_list(events) do
    note = %Note{number: number, velocity: 0}
    notes_on = notes_on |> Map.delete(number)
    %{events: [{time, note} | events], notes_on: notes_on}
  end

  @doc """
  Add control change to events.
  """
  def control_change(time, key, value, %{events: events} = channel_state) do
    put_in(channel_state.events, [{time, {key, value}} | events])
  end

  def init_state(channel, state) do
    if state.channels[channel] == nil do
      put_in(state.channels[channel], %{events: [], notes_on: %{}})
    else
      state
    end
  end

  # 1001nnnn
  @note_on 144
  # 1000nnnn
  @note_off 128
  # 1011nnnn
  @control_change 176

  def handle_message(@note_on, note, 0, channel, port_id, time, state) do
    handle_message(@note_off, note, 0, channel, port_id, time, state)
  end

  def handle_message(@note_on, note, velocity, channel, _port_id, time, state) do
    state = init_state(channel, state)
    updated = note_on(time, note, velocity, state.channels[channel])
    put_in(state.channels[channel], updated)
  end

  def handle_message(@note_off, note, 0, channel, _port_id, time, state) do
    if state.channels[channel] != nil do
      updated = note_off(time, note, state.channels[channel])
      put_in(state.channels[channel], updated)
    end
  end

  def handle_message(@control_change, key, value, channel, _port_id, time, state) do
    state = init_state(channel, state)
    updated = control_change(time, key, value, state.channels[channel])
    put_in(state.channels[channel], updated)
  end
end
