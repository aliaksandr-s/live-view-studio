defmodule LiveViewStudioWeb.CustomComponents do
  use Phoenix.Component
  
  attr :expiration, :integer, default: 24
  slot :legal
  slot :inner_block, required: true

  def promo(assigns) do
    # assigns = assign(assigns, :minutes, assigns.expiration * 60)
    assigns = assign_new(assigns, :minutes, fn -> assigns.expiration * 60 end)

    ~H"""
    <div class="promo">
      <div class="deal">
        <%= render_slot(@inner_block) %>
      </div>
      <div class="expiration">
        Deal expires in <%= @minutes %> minutes.
      </div>
      <div class="legal">
        <%= render_slot(@legal) %>
      </div>
    </div>
    """
  end

  attr :visible, :boolean, default: false

  def loader(assigns) do
    ~H"""
    <div class="loader" :if={@visible}>
      Loading...
    </div>
    """
  end
end
