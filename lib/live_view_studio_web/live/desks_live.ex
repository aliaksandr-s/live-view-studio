defmodule LiveViewStudioWeb.DesksLive do
  use LiveViewStudioWeb, :live_view

  alias LiveViewStudio.Desks
  alias LiveViewStudio.Desks.Desk

  def mount(_params, _session, socket) do
    if connected?(socket), do: Desks.subscribe()

    socket =
      assign(socket,
        form: to_form(Desks.change_desk(%Desk{}))
      )

    socket =
      allow_upload(
        socket,
        :photos,
        accept: ~w(.jpg .jpeg .png),
        max_entries: 3,
        max_file_size: 10_000_000
      )

    {:ok, stream(socket, :desks, Desks.list_desks())}
  end

  def handle_event("cancel", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :photos, ref)}
  end

  def handle_event("validate", %{"desk" => params}, socket) do
    changeset =
      %Desk{}
      |> Desks.change_desk(params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"desk" => params}, socket) do
    # copy temp file to priv/static/uploads/abc-1.png
    # URL path: /uploads/abc-1.png

    photo_locations =
      consume_uploaded_entries(socket, :photos, fn meta, entry ->
        IO.inspect(meta, label: "meta")
        IO.inspect(entry, label: "entry")

        dest =
          Path.join([
            "priv",
            "static",
            "uploads",
            "#{entry.uuid}-#{entry.client_name}"
          ])

        File.mkdir_p!(Path.dirname(dest))
        File.cp!(meta.path, dest)

        url_path = static_path(socket, "/uploads/#{Path.basename(dest)}")

        {:ok, url_path}
      end)

    params = Map.put(params, "photo_locations", photo_locations)

    case Desks.create_desk(params) do
      {:ok, _desk} ->
        changeset = Desks.change_desk(%Desk{})
        {:noreply, assign_form(socket, changeset)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  def handle_info({:desk_created, desk}, socket) do
    {:noreply, stream_insert(socket, :desks, desk, at: 0)}
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp error_to_string(:too_large),
    do: "Gulp! File too large (max 10 MB)."

  defp error_to_string(:too_many_files),
    do: "Whoa, too many files."

  defp error_to_string(:not_accepted),
    do: "Sorry, that's not an acceptable file type."
end
