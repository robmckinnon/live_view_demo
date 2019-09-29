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

  @nil_duration nil
  @nil_beats nil

  @doc """
  Add note to events and notes.
  """
  def note_on(time, initial_time, ms_per_beat, number, velocity, %{
        events: events,
        notes_on: notes_on
      })
      when is_integer(number) and is_integer(velocity) and
             is_map(notes_on) and is_list(events) do
    note = %Note{number: number, velocity: velocity}
    notes_on = notes_on |> Map.put(number, note)

    %{
      events: [{time, time - initial_time, @nil_duration, @nil_beats, note} | events],
      notes_on: notes_on
    }
  end

  defp note_duration(_number, _end_time, _ms_per_beat, []) do
    []
  end

  defp note_duration(number, end_time, ms_per_beat, [
         {start_time, rel_time, @nil_duration, @nil_beats, %Note{number: number} = note} | events
       ]) do
    duration = end_time - start_time
    beats = duration / ms_per_beat
    [{start_time, rel_time, duration, duration / ms_per_beat, note} | events]
  end

  defp note_duration(number, end_time, ms_per_beat, [
         {start_time, rel_time, @nil_duration, @nil_beats, %Note{} = note} | events
       ]) do
    events = note_duration(number, end_time, ms_per_beat, events)
    [{start_time, rel_time, @nil_duration, @nil_beats, note} | events]
  end

  @doc """
  Add note off to events and remove from notes.
  """
  def note_off(time, initial_time, ms_per_beat, number, %{events: events, notes_on: notes_on})
      when is_integer(number) and is_map(notes_on) and is_list(events) do
    note = %Note{number: number, velocity: 0}
    notes_on = notes_on |> Map.delete(number)
    events = note_duration(number, time, ms_per_beat, events)

    %{
      events: [{time, time - initial_time, @nil_duration, @nil_beats, note} | events],
      notes_on: notes_on
    }
  end

  @doc """
  Add control change to events.
  """
  def control_change(time, initial_time, key, value, %{events: events} = channel_state) do
    put_in(channel_state.events, [{time, time - initial_time, {key, value}} | events])
  end

  def init_time(%{initial_time: nil} = state, time), do: %{state | initial_time: time}
  def init_time(state, _time), do: state

  def init_state(channel, state, time) do
    state = init_time(state, time)

    if state.channels[channel] == nil do
      put_in(state.channels[channel], %{events: [], notes_on: %{}})
    else
      state
    end
  end

  def inc_tempo(state) do
    state = put_in(state.bpm, min(240, state.bpm + 1))
    put_in(state.ms_per_beat, 60000 / state.bpm)
  end

  def dec_tempo(state) do
    state = put_in(state.bpm, max(1, state.bpm - 1))
    put_in(state.ms_per_beat, 60000 / state.bpm)
  end

  # 1001nnnn
  @note_on 144
  # 1000nnnn
  @note_off 128
  # 1011nnnn
  @control_change 176
  # 1100nnnn
  @program_change 192

  def handle_message(@note_on, note, 0, channel, port_id, time, state) do
    handle_message(@note_off, note, 0, channel, port_id, time, state)
  end

  def handle_message(@note_on, note, velocity, channel, _port_id, time, state) do
    state = init_state(channel, state, time)

    updated =
      note_on(
        time,
        state.initial_time,
        state.ms_per_beat,
        note,
        velocity,
        state.channels[channel]
      )

    put_in(state.channels[channel], updated)
  end

  def handle_message(@note_off, note, 0, channel, _port_id, time, state) do
    if state.channels[channel] != nil do
      updated =
        note_off(time, state.initial_time, state.ms_per_beat, note, state.channels[channel])

      put_in(state.channels[channel], updated)
    end
  end

  def handle_message(@control_change, key, value, channel, _port_id, time, state) do
    state = init_state(channel, state, time)

    IO.puts([
      "CC ",
      Integer.to_string(key),
      " ",
      Integer.to_string(value),
      " ",
      Integer.to_string(channel)
    ])

    updated = control_change(time, state.initial_time, key, value, state.channels[channel])
    put_in(state.channels[channel], updated)
  end

  def handle_message(@program_change, number, channel, _port_id, _time, state) do
    IO.puts([
      "PC ",
      Integer.to_string(number),
      " ",
      Integer.to_string(channel)
    ])

    state
  end
end
