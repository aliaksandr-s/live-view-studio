defmodule LiveViewStudioWeb.LightLive do
  use LiveViewStudioWeb, :live_view

  def mount(_params, _session, socket) do
    socket = assign(socket, :brightness, 10)
    {:ok, socket}
  end

  def handle_event("on", _, socket) do
    socket = assign(socket, :brightness, 100)
    {:noreply, socket}
  end

  def handle_event("up", _, socket) do
    socket = update(socket, :brightness, &min(&1 + 10, 100))
    {:noreply, socket}
  end

  def handle_event("down", _, socket) do
    socket = update(socket, :brightness, &max(&1 - 10, 0))
    {:noreply, socket}
  end

  def handle_event("off", _, socket) do
    socket = assign(socket, :brightness, 0)
    {:noreply, socket}
  end

  def handle_event("rand", _, socket) do
    socket = assign(socket, :brightness, Enum.random(0..100))
    {:noreply, socket}
  end

  def render(assigns) do
  ~H"""
    <h1>Front porch light</h1>
    <div id="light" class="light">
      <div class="meter">
        <span style={"width: #{@brightness}%"}>
          <%= @brightness %>%
        </span>
      </div>
      <button phx-click="off">
        <img src="./images/light-off.svg" alt="Light off" />
      </button>
      <button phx-click="down">
        <img src="./images/down.svg" alt="Light down" />
      </button>
      <button phx-click="up">
        <img src="./images/up.svg" alt="Light up" />
      </button>
      <button phx-click="on">
        <img src="./images/light-on.svg" alt="Light off" />
      </button>
      <button phx-click="rand">
        <img src="./images/fire.svg" alt="Fire" />
      </button>
    </div>
  """
  end
end