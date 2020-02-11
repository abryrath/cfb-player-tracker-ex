defmodule PTracker.Api.Router do
  use Plug.Router

  plug :match
  plug :dispatch

  get "/clemson" do
    send_resp(conn, 200, "Clemson")
  end
end
