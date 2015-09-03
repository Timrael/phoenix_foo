defmodule PhoenixFoo.HotelView do
  use PhoenixFoo.Web, :view

  def render("show.json", %{hotels: hotels}) do
    hotels
  end
end
