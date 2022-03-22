defmodule ApiBlogs.Blog.User do
  use Ecto.Schema
  import Ecto.Changeset

  @fields ~w(displayName email password image)a
  @required_fields ~w(email password)a

  schema "users" do
    field :displayName, :string
    field :email, :string
    field :image, :string
    field :password, :string

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, @fields)
    |> validate_required(@required_fields)
    |> unique_constraint(:email, message: "Usuario ja existe")
    |> validate_format(:email, ~r/.@./)
    |> validate_length(:displayName, min: 8)
    |> validate_length(:password, min: 6)
  end
end
