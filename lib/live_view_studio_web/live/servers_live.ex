defmodule LiveViewStudioWeb.ServersLive do
  use LiveViewStudioWeb, :live_view

  alias LiveViewStudio.Servers
  alias LiveViewStudioWeb.ServerFormComponent

  def mount(_params, _session, socket) do
    if connected?(socket) do
      Servers.subscribe()
    end

    servers = Servers.list_servers()

    socket =
      assign(socket,
        servers: servers,
        coffees: 0
      )

    {:ok, socket}
  end

  def handle_info({:server_created, server}, socket) do
    socket =
      update(
        socket,
        :servers,
        fn servers -> [server | servers] end
      )

    {:noreply, socket}
  end

  def handle_info({:server_updated, server}, socket) do
    # If the updated server is the selected server,
    # assign it so the status button is re-rendered:
    socket =
      if server.id == socket.assigns.selected_server.id do
        assign(socket, selected_server: server)
      else
        socket
      end

    socket =
      update(socket, :servers, fn servers ->
        for s <- servers do
          if s.id == server.id, do: server, else: s
        end
      end)

    {:noreply, socket}
  end

  def handle_params(%{"id" => id}, _uri, socket) do
    server = Servers.get_server!(id)

    {:noreply,
     assign(
       socket,
       selected_server: server,
       page_title: "What's up #{server.name}?"
     )}
  end

  def handle_params(_, _uri, socket) do
    socket =
      if socket.assigns.live_action == :new do
        assign(socket,
          selected_server: nil
        )
      else
        assign(socket,
          selected_server: hd(socket.assigns.servers)
        )
      end

    {:noreply, socket}
  end

  def handle_event("drink", _, socket) do
    {:noreply, update(socket, :coffees, &(&1 + 1))}
  end

  def handle_event("toggle-status", %{"id" => id}, socket) do
    server = Servers.get_server!(id)

    new_status = if server.status == "up", do: "down", else: "up"

    {:ok, _server} =
      Servers.update_server(
        server,
        %{status: new_status}
      )

    {:noreply, socket}
  end

  attr :server, LiveViewStudio.Servers.Server, required: true

  def server(assigns) do
    ~H"""
    <div class="header">
      <h2><%= @server.name %></h2>
      <button
        class={@server.status}
        phx-click="toggle-status"
        phx-value-id={@server.id}
      >
        <%= @server.status %>
      </button>
    </div>
    <div class="body">
      <div class="row">
        <span>
          <%= @server.deploy_count %> deploys
        </span>
        <span>
          <%= @server.size %> MB
        </span>
        <span>
          <%= @server.framework %>
        </span>
      </div>
      <h3>Last Commit Message:</h3>
      <blockquote>
        <%= @server.last_commit_message %>
      </blockquote>
    </div>
    """
  end

  def render(assigns) do
    ~H"""
    <h1>Servers</h1>
    <div id="servers">
      <div class="sidebar">
        <div class="nav">
          <.link patch={~p"/servers/new"} class="add">
            + Add New Server
          </.link>
          <.link
            :for={server <- @servers}
            patch={~p"/servers?#{[id: server]}"}
            patch={~p"/servers/#{server}"}
            class={if server == @selected_server, do: "selected"}
          >
            <span class={server.status}></span>
            <%= server.name %>
          </.link>
        </div>
        <div class="coffees">
          <button phx-click="drink">
            <img src="/images/coffee.svg" />
            <%= @coffees %>
          </button>
        </div>
      </div>
      <div class="main">
        <div class="wrapper" id="current-server">
          <div class="server">
            <%= if @live_action == :new do %>
              <.live_component module={ServerFormComponent} id="new" />
            <% else %>
              <.server server={@selected_server} />
            <% end %>
          </div>

          <div class="links">
            <.link navigate={~p"/light"}>Adjust light</.link>
            <.link navigate={~p"/topsecret"}>Top Secret</.link>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
