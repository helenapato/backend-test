defmodule ApiBlogs.Blog.Post do
  use Ecto.Schema
  import Ecto.Changeset

  @fields ~w(title content user_id)a

  schema "posts" do
    field :content, :string
    field :title, :string
    field :user_id, :id

    timestamps()
  end

  @doc false
  def changeset(post, attrs) do
    post
    |> cast(attrs, @fields)
    |> validate_required(@fields)
    |> foreign_key_constraint(:user_id)
  end
end
