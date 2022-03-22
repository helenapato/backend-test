defmodule ApiBlogsWeb.PostView do
  use ApiBlogsWeb, :view
  alias ApiBlogsWeb.PostView
  alias ApiBlogs.Blog

  def render("index.json", %{posts: posts}) do
    %{data: render_many(posts, PostView, "post.json")}
  end

  def render("show.json", %{post: post}) do
    %{data: render_one(post, PostView, "post.json")}
  end

  def render("post.json", %{post: post}) do
    with user <- Blog.get_user!(post.user_id) do
      %{
        id: post.id,
        title: post.title,
        content: post.content,
        published: post.inserted_at,
        updated: post.updated_at,
        user: %{
          id: user.id,
          displayName: user.displayName,
          email: user.email,
          image: user.image
        }
      }
    end
  end

  def render("create.json", %{post: post}) do
    %{
      title: post.title,
      content: post.content,
      user_id: post.user_id
    }
  end
end
