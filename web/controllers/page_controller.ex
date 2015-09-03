defmodule PhoenixFoo.PageController do
  use PhoenixFoo.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
