defmodule ApiBlogs.Repo.Migrations.DropPublishedUpdated do
  use Ecto.Migration

  def change do
    alter table("posts") do
      remove :published, :naive_datetime
      remove :updated, :naive_datetime
    end
  end
end
