defmodule ApiBlogsWeb.UserController do
  use ApiBlogsWeb, :controller

  alias ApiBlogs.Blog
  alias ApiBlogs.Blog.User
  alias ApiBlogs.Guardian

  action_fallback ApiBlogsWeb.FallbackController

  def index(conn, _params) do
    users = Blog.list_users()
    render(conn, "index.json", users: users)
  end

  def create(conn, %{"user" => user_params}) do
    with {:ok, %User{} = user} <- Blog.create_user(user_params),
         {:ok, token, _claims} <- Guardian.encode_and_sign(user) do
      conn
      |> put_status(:created)
      |> render("jwt.json", jwt: token)
    end
  end

  def show(conn, %{"id" => id}) do
    id
    |> Blog.get_user()
    |> user_exists(conn)
  end

  defp user_exists(nil, _conn), do: {:error, :not_found, "Usuario nao existe"}
  defp user_exists(user, conn), do: render(conn, "show.json", user: user)

  # def update(conn, %{"id" => id, "user" => user_params}) do
  #   user = Blog.get_user!(id)

  #   with {:ok, %User{} = user} <- Blog.update_user(user, user_params) do
  #     render(conn, "show.json", user: user)
  #   end
  # end

  def delete(conn, _params) do
    with {:ok, %{"sub" => id}} <- extract_id(conn),
      user <- Blog.get_user!(id),
      {:ok, %User{}} <- Blog.delete_user(user) do
        send_resp(conn, :no_content, "")
      end
  end

  def extract_id(conn) do
    conn.private[:guardian_default_token]
    |> Guardian.decode_and_verify()
  end

  def login(conn, %{"user" => user_params}) do
    with {:ok, %{} = user} <- Blog.do_login(user_params),
         {:ok, token, _claims} <- Guardian.encode_and_sign(user) do
      conn
      |> render("jwt.json", jwt: token)
    end
  end
end
