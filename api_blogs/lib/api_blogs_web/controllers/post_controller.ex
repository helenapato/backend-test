defmodule ApiBlogsWeb.PostController do
  use ApiBlogsWeb, :controller

  alias ApiBlogs.Blog
  alias ApiBlogs.Blog.Post
  alias ApiBlogsWeb.UserController

  action_fallback ApiBlogsWeb.FallbackController

  def index(conn, _params) do
    posts_users = Blog.list_posts_with_users()
    render(conn, "index.json", posts_users: posts_users)
  end

  def create(conn, %{"post" => post_params}) do
    with {:ok, %{} = new_post} <- Blog.add_params_create_post(conn, post_params),
         {:ok, %Post{} = post} <- Blog.create_post(new_post) do
      conn
      |> put_status(:created)
      |> render("create.json", post: post)
    end
  end

  def show(conn, %{"id" => id}) do
    with {:ok, %Post{} = post} <- Blog.get_post(id),
         post_user <- Blog.get_post_user(post) do
      render(conn, "show.json", post_user: post_user)
    end
  end

  def update(conn, %{"id" => id, "post" => post_params}) do
    with {:ok, %Post{} = post} <- Blog.get_post(id),
         {:ok, %Post{} = post} <- Blog.check_valid_update(conn, post, post_params),
         {:ok, %Post{} = post} <- Blog.update_post(post, post_params) do
      render(conn, "create.json", post: post)
    end
  end

  def delete(conn, %{"id" => id}) do
    post = Blog.get_post!(id)

    with {:ok, %Post{}} <- Blog.delete_post(post) do
      send_resp(conn, :no_content, "")
    end
  end
end
