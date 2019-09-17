defmodule LiveViewDemo.MidiTest do
  @moduledoc false
  use ExUnit.Case

  alias LiveViewDemo.Midi

  describe "state" do
    alias LiveViewDemo.Midi.State

    test "initialised with channels map" do
      state = struct(State)
      assert state.channels == %{}
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
