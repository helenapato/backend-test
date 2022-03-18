defmodule ApiBlogsWeb.PostController do
  use ApiBlogsWeb, :controller

  alias ApiBlogs.Blog
  alias ApiBlogs.Blog.Post
  alias ApiBlogsWeb.UserController

  action_fallback ApiBlogsWeb.FallbackController

  def index(conn, _params) do
    posts = Blog.list_posts()
    render(conn, "index.json", posts: posts)
  end

  def create(conn, %{"post" => %{"content" => content, "title" => title}}) do
    {:ok, %{"sub" => id}} = UserController.extract_id(conn)
    time_now = NaiveDateTime.utc_now()

    new_post = %{
      "content" => content,
      "published" => time_now,
      "title" => title,
      "updated" => time_now,
      "user_id" => id
    }

    with {:ok, %Post{} = post} <- Blog.create_post(new_post) do
      conn
      |> put_status(:created)
      |> render("create.json", post: post)
    end
  end

  def create(_conn, %{"post" => _post_params}) do
    {:error, :missing_title_content}
  end

  def show(conn, %{"id" => id}) do
    post = Blog.get_post!(id)
    render(conn, "show.json", post: post)
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
