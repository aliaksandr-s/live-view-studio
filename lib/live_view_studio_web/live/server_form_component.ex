defmodule LiveViewStudioWeb.ServerFormComponent do
  use LiveViewStudioWeb, :live_component

  alias LiveViewStudio.Servers
  alias LiveViewStudio.Servers.Server

  def mount(socket) do
    changeset = Servers.change_server(%Server{})

    {:ok, assign(socket, :form, to_form(changeset))}
  end

  def handle_event("validate", %{"server" => server_params}, socket) do
    changeset =
      %Server{}
      |> Server.changeset(server_params)
      |> Map.put(:action, :validate)

    socket = assign(socket, form: to_form(changeset))

    {:noreply, socket}
  end

  def handle_event("save", %{"server" => server_params}, socket) do
    case Servers.create_server(server_params) do
      {:ok, server} ->
        send(self(), {:server_created, server})

        {:noreply, socket}

      {:error, changeset} ->
        socket = put_flash(socket, :error, "Error creating server!")
        socket = assign(socket, form: to_form(changeset))

        {:noreply, socket}
    end
  end

  def render(assigns) do
    ~H"""
    <div>
      <.form
        for={@form}
        phx-submit="save"
        phx-change="validate"
        phx-target={@myself}
      >
        <div class="field">
          <.input
            field={@form[:name]}
            placeholder="Name"
            autocomplete="off"
          />
        </div>
        <div class="field">
          <.input
            field={@form[:framework]}
            placeholder="Framework"
            autocomplete="off"
          />
        </div>
        <div class="field">
          <.input
            field={@form[:size]}
            placeholder="Size (MB)"
            autocomplete="off"
          />
        </div>
        <.button phx-disable-with="Saving...">
          Save
        </.button>
        <.link patch={~p"/servers"} class="cancel">
          Cancel
        </.link>
      </.form>
    </div>
    """
  end
end
