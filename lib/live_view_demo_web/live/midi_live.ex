defmodule LiveViewDemoWeb.MidiLive do
  use Phoenix.LiveView

  alias LiveViewDemo.Midi
  alias LiveViewDemo.Midi.State

  def render(assigns) do
    LiveViewDemoWeb.MidiView.render("index.html", assigns)
  end

  def mount(_session, socket) do
    {:ok, assign(socket, state: struct(State))}
  end

  def handle_event("user_gesture", _value, %{assigns: assigns} = socket) do
    new_state = Midi.user_gesture(assigns.state)
    {:noreply, assign(socket, state: new_state)}
  end
end
