defmodule LiveViewDemo.Midi do
  @moduledoc """
  The MIDI context.
  """

  alias LiveViewDemo.Midi.Note
  alias LiveViewDemo.Midi.State

  def user_gesture(%State{user_gesture: false} = state) do
    %{state | user_gesture: true}
  end

  @doc """
  Add note to events and notes.
  """
  def note_on(time, number, velocity, %{events: events, notes_on: notes_on})
      when is_integer(time) and is_integer(number) and is_integer(velocity) and
             is_map(notes_on) and is_list(events) do
    note = %Note{number: number, velocity: velocity}
    notes_on = notes_on |> Map.put(number, note)
    %{events: [{time, note} | events], notes_on: notes_on}
  end

  @doc """
  Add note off to events and remove froms notes.
  """
  def note_off(time, number, %{events: events, notes_on: notes_on})
      when is_integer(time) and is_integer(number) and
             is_map(notes_on) and is_list(events) do
    note = %Note{number: number, velocity: 0}
    notes_on = notes_on |> Map.delete(number)
    %{events: [{time, note} | events], notes_on: notes_on}
  end
end
