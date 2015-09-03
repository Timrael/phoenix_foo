defmodule PhoenixFoo.HotelController do
  use PhoenixFoo.Web, :controller

  def show(conn, params) do
    render conn, hotels: PhoenixFoo.Storage.show(params["city_name"], params["order"] || "asc")
  end
end
