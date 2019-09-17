defmodule LiveViewDemoWeb.MidiLive do
  use Phoenix.LiveView

  alias LiveViewDemo.Midi.State

  def render(assigns) do
    LiveViewDemoWeb.MidiView.render("index.html", assigns)
  end

  def mount(_session, socket) do
    {:ok, assign(socket, state: struct(State))}
  end
end
