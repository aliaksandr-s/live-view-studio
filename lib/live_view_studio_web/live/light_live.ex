defmodule LiveViewStudioWeb.LightLive do
  use LiveViewStudioWeb, :live_view

  def mount(_params, _session, socket) do
    socket =
      assign(socket,
        brightness: 10,
        temp: "3000"
      )

    {:ok, socket}
  end

  def handle_event("update", %{"key" => "ArrowUp"}, socket) do
    {:noreply, brightness_up(socket)}
  end

  def handle_event("update", %{"key" => "ArrowDown"}, socket) do
    {:noreply, brightness_down(socket)}
  end

  def handle_event("update", _, socket) do
    {:noreply, socket}
  end

  def handle_event("on", _, socket) do
    socket = assign(socket, :brightness, 100)
    {:noreply, socket}
  end

  def handle_event("up", _, socket) do
    {:noreply, brightness_up(socket)}
  end

  def handle_event("down", _, socket) do
    {:noreply, brightness_down(socket)}
  end

  def handle_event("off", _, socket) do
    socket = assign(socket, :brightness, 0)
    {:noreply, socket}
  end

  def handle_event("rand", _, socket) do
    socket = assign(socket, :brightness, Enum.random(0..100))
    {:noreply, socket}
  end

  def handle_event("slide", %{"brightness" => brightness}, socket) do
    socket = assign(socket, brightness: String.to_integer(brightness))
    {:noreply, socket}
  end

  def handle_event("select", %{"temp" => temp}, socket) do
    socket = assign(socket, temp: temp)
    {:noreply, socket}
  end

  defp temp_color(temp) do
    case temp do
      "3000" -> "#F1C40D"
      "4000" -> "#FEFF66"
      "5000" -> "#99CCFF"
    end
  end

  # Helper functions

  defp brightness_up(socket) do
    update(socket, :brightness, &min(&1 + 10, 100))
  end

  defp brightness_down(socket) do
    update(socket, :brightness, &max(&1 - 10, 0))
  end
end
