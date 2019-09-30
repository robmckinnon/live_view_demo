defmodule LiveViewDemo.Midi.MessageHandlerTest do
  @moduledoc false
  use ExUnit.Case

  alias LiveViewDemo.Midi.MessageHandler

  describe "MessageHandler" do
    alias LiveViewDemo.Midi.Note

    @blank_grid %{
      ones: [],
      halves: [],
      quarters: []
    }

    test "note_on adds note to events list and notes_on map" do
      ms_per_beat = 500
      number = 49
      velocity = 50
      initial_time = 1_052_287.6999999862
      time = initial_time
      rel_time = 0
      nil_duration = nil
      nil_beats = nil

      state =
        MessageHandler.note_on(time, initial_time, ms_per_beat, number, velocity, %{
          events: [],
          notes_on: %{},
          grid: @blank_grid
        })

      assert Enum.count(state.events) == 1

      assert state.events == [
               {initial_time, rel_time, nil_duration, nil_beats,
                %Note{number: number, velocity: velocity}}
             ]

      assert state.grid == @blank_grid

      assert state.notes_on == %{number => %Note{number: number, velocity: velocity}}
    end

    test "note_off adds note to events list and removes from notes_on map" do
      ms_per_beat = 500
      number = 49
      velocity = 50
      initial_time = 1_052_287.6999999862
      time2 = 1_062_917.9749999894
      rel_time = 0
      rel_time2 = time2 - initial_time
      nil_duration = nil
      nil_beats = nil
      duration = rel_time2
      beats = duration / ms_per_beat
      note = %Note{number: number, velocity: velocity}

      state = %{
        events: [{initial_time, rel_time, nil_duration, nil_beats, note}],
        notes_on: %{number => note},
        grid: @blank_grid
      }

      state = MessageHandler.note_off(time2, initial_time, ms_per_beat, number, state)

      assert Enum.count(state.events) == 2

      assert state.events == [
               {time2, rel_time2, nil_duration, nil_beats, %Note{number: number, velocity: 0}},
               {initial_time, rel_time, duration, beats,
                %Note{number: number, velocity: velocity}}
             ]

      assert state.notes_on == %{}
    end
  end
end
