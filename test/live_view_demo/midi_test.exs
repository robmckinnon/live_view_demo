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
      assert state.initial_time == nil
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
      rel_time = 0
      nil_duration = nil
      nil_beats = nil
      state = Midi.handle_message(144, 59, 127, channel, port_id, time, state)

      assert state.channels |> Map.get(channel) ==
               %{
                 events: [
                   {time, rel_time, nil_duration, nil_beats,
                    %LiveViewDemo.Midi.Note{number: 59, velocity: 127}}
                 ],
                 notes_on: %{59 => %LiveViewDemo.Midi.Note{number: 59, velocity: 127}},
                 grid: []
               }

      assert state.initial_time == time
    end

    test "handle_message adds note off and grid entry" do
      state = struct(State)
      channel = 11
      port_id = "1649372164"
      time = 1_052_287.6999999862
      time2 = 1_062_917.9749999894
      rel_time = 0.0
      rel_time2 = time2 - time
      nil_duration = nil
      nil_beats = nil
      duration = time2 - time
      beats = duration / state.ms_per_beat
      state = Midi.handle_message(144, 59, 127, channel, port_id, time, state)
      state = Midi.handle_message(128, 59, 0, channel, port_id, time2, state)

      assert state.channels |> Map.get(channel) ==
               %{
                 events: [
                   {time2, rel_time2, nil_duration, nil_beats,
                    %LiveViewDemo.Midi.Note{number: 59, velocity: 0}},
                   {time, rel_time, duration, beats,
                    %LiveViewDemo.Midi.Note{number: 59, velocity: 127}}
                 ],
                 notes_on: %{},
                 grid: [[{59}, {0, 0}, {10625, 85}]]
               }

      assert state.initial_time == time
    end

    test "handle_message adds control change" do
      state = struct(State)
      channel = 11
      port_id = "1649372164"
      time = 1_052_287.6999999862
      rel_time = 0
      state = Midi.handle_message(176, 59, 127, channel, port_id, time, state)

      assert state.channels |> Map.get(channel) ==
               %{
                 events: [
                   {time, rel_time, {59, 127}}
                 ],
                 notes_on: %{},
                 grid: []
               }

      assert state.initial_time == time
    end
  end
end
