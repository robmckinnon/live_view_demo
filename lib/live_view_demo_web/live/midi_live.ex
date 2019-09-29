defmodule LiveViewDemoWeb.MidiLive do
  use Phoenix.LiveView
  use Bitwise, only_operators: true

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

  def handle_event("midi_input", input, %{assigns: assigns} = socket) do
    new_state = Midi.midi_input(input, assigns.state)
    {:noreply, assign(socket, state: new_state)}
  end

  def handle_event("midi_output", output, %{assigns: assigns} = socket) do
    new_state = Midi.midi_output(output, assigns.state)
    {:noreply, assign(socket, state: new_state)}
  end

  def handle_event("inc_tempo", _, %{assigns: assigns} = socket) do
    new_state = Midi.inc_tempo(assigns.state)
    {:noreply, assign(socket, state: new_state)}
  end

  def handle_event("dec_tempo", _, %{assigns: assigns} = socket) do
    new_state = Midi.dec_tempo(assigns.state)
    {:noreply, assign(socket, state: new_state)}
  end

  def handle_event(
        "m",
        %{
          "d" => %{"0" => status, "1" => key, "2" => value},
          "i" => port_id,
          "t" => time
        },
        %{assigns: assigns} = socket
      ) do
    message_code = status &&& 0xF0
    channel = (status &&& 0x0F) + 1
    IO.inspect(time)

    new_state =
      Midi.handle_message(message_code, key, value, channel, port_id, time, assigns.state)

    {:noreply, assign(socket, state: new_state)}
  end

  def handle_event(
        "m",
        %{
          "d" => %{"0" => status, "1" => key},
          "i" => port_id,
          "t" => time
        },
        %{assigns: assigns} = socket
      ) do
    message_code = status &&& 0xF0
    channel = (status &&& 0x0F) + 1

    new_state = Midi.handle_message(message_code, key, channel, port_id, time, assigns.state)

    {:noreply, assign(socket, state: new_state)}
  end
end
