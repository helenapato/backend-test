defmodule ApiBlogsWeb.PostView do
  use ApiBlogsWeb, :view
  alias ApiBlogsWeb.PostView

  def render("index.json", %{posts_users: posts_users}) do
    %{data: render_many(posts_users, PostView, "post.json")}
  end

  def render("show.json", %{post: post}) do
    %{data: render_one(post, PostView, "post.json")}
  end

  def render("post.json", %{post: %{post: post, user: user}}) do
    %{
      id: post.id,
      title: post.title,
      content: post.content,
      published: post.inserted_at,
      updated: post.updated_at,
      user: render("user.json", %{user: user})
    }
  end

  def render("user.json", %{user: user}) do
    %{
      id: user.id,
      displayName: user.displayName,
      email: user.email,
      image: user.image
    }
  end

  def render("create.json", %{post: post}) do
    %{
      title: post.title,
      content: post.content,
      user_id: post.user_id
    }
  end
end
