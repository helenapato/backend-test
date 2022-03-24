defmodule ApiBlogsWeb.PostController do
  use ApiBlogsWeb, :controller

  alias ApiBlogs.Blog
  alias ApiBlogs.Blog.Post
  alias ApiBlogsWeb.UserController

  action_fallback ApiBlogsWeb.FallbackController

  def index(conn, _params) do
    posts_users =
      Blog.list_posts()
      |> get_post_user()
    render(conn, "index.json", posts_users: posts_users)
  end

  defp get_post_user([]), do: []
  defp get_post_user([post | posts]) do
    with user <- Blog.get_user!(post.user_id) do
      [ %{post: post, user: user} | get_post_user(posts)]
    end
  end
  defp get_post_user(post) do
    with user <- Blog.get_user!(post.user_id) do
      %{post: post, user: user}
    end
  end

  def create(conn, %{"post" => post_params}) do
    {:ok, %{"sub" => id}} = UserController.extract_id(conn)
    new_post = Map.put(post_params, "user_id", id)

    with {:ok, %Post{} = post} <- Blog.create_post(new_post) do
      conn
      |> put_status(:created)
      |> render("create.json", post: post)
    end
  end

  def show(conn, %{"id" => id}) do
    try do
      post_user =
        id
        |> Blog.get_post!()
        |> get_post_user()
      render(conn, "show.json", post_user: post_user)
    rescue
      Ecto.NoResultsError -> {:error, :not_found, "Post nao existe"}
    end
  end

  def update(conn, %{"id" => id, "post" => post_params}) do
    post = Blog.get_post!(id)

    with {:ok, %Post{} = post} <- Blog.update_post(post, post_params) do
      render(conn, "show.json", post: post)
    end
  end

  def delete(conn, %{"id" => id}) do
    post = Blog.get_post!(id)

    with {:ok, %Post{}} <- Blog.delete_post(post) do
      send_resp(conn, :no_content, "")
    end
  end
end
