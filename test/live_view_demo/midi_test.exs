defmodule LiveViewDemo.MidiTest do
  @moduledoc false
  use ExUnit.Case

  alias LiveViewDemo.Midi

  describe "state" do
    alias LiveViewDemo.Midi.{Port, State}

    test "initialised with channels map, user_gesture false, inputs/outputs empty" do
      state = struct(State)
      assert state.channels == %{}
      assert state.user_gesture == false
      assert state.inputs == %{}
      assert state.outputs == %{}
      assert state.bpm == 120
      assert state.ms_per_beat == 500
    end

    @port %{
      "id" => "id",
      "manufacturer" => "manufacturer",
      "name" => "name",
      "type" => "type",
      "version" => "version",
      "state" => "state",
      "connection" => "connection"
    }

    test "adds midi_input" do
      state = struct(State)
      input = @port
      state = Midi.midi_input(input, state)
      assert %Port{} = state.inputs |> Map.get("id")
    end

    test "adds midi_output" do
      state = struct(State)
      output = @port
      state = Midi.midi_output(output, state)
      assert %Port{} = state.outputs |> Map.get("id")
    end

    test "increments tempo" do
      state = struct(State)
      state = Midi.inc_tempo(state)
      assert state.bpm == 121

      state = %{state | bpm: 240}
      state = Midi.inc_tempo(state)
      assert state.bpm == 240
      assert state.ms_per_beat == 250
    end

    test "decrements tempo" do
      state = struct(State)
      state = Midi.dec_tempo(state)
      assert state.bpm == 119

      state = %{state | bpm: 1}
      state = Midi.dec_tempo(state)
      assert state.bpm == 1
    end

    test "handle_message adds new note on" do
      state = struct(State)
      channel = 11
      port_id = "1649372164"
      time = 1_052_287.6999999862
      state = Midi.handle_message(144, 59, 127, channel, port_id, time, state)

      assert state.channels |> Map.get(channel) ==
               %{
                 events: [{time, %LiveViewDemo.Midi.Note{number: 59, velocity: 127}}],
                 notes_on: %{59 => %LiveViewDemo.Midi.Note{number: 59, velocity: 127}}
               }
    end

    test "handle_message adds note off" do
      state = struct(State)
      channel = 11
      port_id = "1649372164"
      time = 1_052_287.6999999862
      state = Midi.handle_message(144, 59, 127, channel, port_id, time, state)
      time2 = 1_062_917.9749999894
      state = Midi.handle_message(128, 59, 0, channel, port_id, time2, state)

      assert state.channels |> Map.get(channel) ==
               %{
                 events: [
                   {time2, %LiveViewDemo.Midi.Note{number: 59, velocity: 0}},
                   {time, %LiveViewDemo.Midi.Note{number: 59, velocity: 127}}
                 ],
                 notes_on: %{}
               }
    end

    test "handle_message adds control change" do
      state = struct(State)
      channel = 11
      port_id = "1649372164"
      time = 1_052_287.6999999862
      state = Midi.handle_message(176, 59, 127, channel, port_id, time, state)

      assert state.channels |> Map.get(channel) ==
               %{
                 events: [
                   {time, {59, 127}}
                 ],
                 notes_on: %{}
               }
    end
  end

  describe "notes" do
    alias LiveViewDemo.Midi.Note

    test "note_on adds note to events list and notes_on map" do
      number = 49
      velocity = 50
      state = Midi.note_on(1, number, velocity, %{events: [], notes_on: %{}})
      assert Enum.count(state.events) == 1

      assert state.events == [
               {1, %Note{number: number, velocity: velocity}}
             ]

      assert state.notes_on == %{number => %Note{number: number, velocity: velocity}}
    end

    test "note_off adds note to events list and removes from notes_on map" do
      number = 49
      velocity = 50
      note = %Note{number: number, velocity: velocity}
      state = %{events: [{1, note}], notes_on: %{number => note}}
      state = Midi.note_off(2, number, state)

      assert Enum.count(state.events) == 2

      assert state.events == [
               {2, %Note{number: number, velocity: 0}},
               {1, %Note{number: number, velocity: velocity}}
             ]

      assert state.notes_on == %{}
    end
  end
end
