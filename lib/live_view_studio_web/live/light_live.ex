defmodule LiveViewStudioWeb.LightLive do
  use LiveViewStudioWeb, :live_view

  def mount(_params, _session, socket) do
    socket = assign(socket, 
      brightness: 10,
      temp: "3000"
    )
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

  def render(assigns) do
  ~H"""
    <h1>Front porch light</h1>
    <div id="light" class="light">
      <div class="meter">
        <span style={"width: #{@brightness}%; background: #{temp_color(@temp)}"}>
          <%= @brightness %>%
        </span>
      </div>
      <form class="mb-10" phx-change="slide">
        <input 
          type="range" min="0" max="100"
          name="brightness" value={@brightness}
        />
      </form>
      <form class="mb-10" phx-change="select">
        <div class="temps">
          <%= for temp <- ["3000", "4000", "5000"] do %>
            <div>
              <input 
                type="radio" id={temp} name="temp" 
                value={temp} checked={temp == @temp} 
              />
              <label for={temp}><%= temp %></label>
            </div>
          <% end %>
        </div>
      </form>
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
