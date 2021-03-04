defmodule TownsKingsWeb.Plugs.StaticPlug do
  @behaviour Plug
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    conn
    |> put_resp_header("content-type", "text/html; charset=utf-8")
    |> send_file(200, Application.app_dir(:towns_kings, "priv/static/index.html"))
  end

end