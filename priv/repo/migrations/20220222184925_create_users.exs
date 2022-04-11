defmodule ApiBlogs.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :displayName, :string
      add :email, :string
      add :password, :string
      add :image, :string

      timestamps()
    end

    create unique_index(:users, [:email])
  end
end
