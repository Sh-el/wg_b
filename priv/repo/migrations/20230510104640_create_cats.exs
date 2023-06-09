defmodule Wg.Repo.Migrations.CreateCats do
  use Ecto.Migration

  @cat_colors [:black, :white, :red, :"black & white", :"red & white", :"red & black & white"]

  def change do
    create table(:cats, primary_key: false) do
      add :name, :string, primary_key: true
      add :color, :cat_color, null: false
      add :tail_length, :integer
      add :whiskers_length, :integer
    end

    execute "CREATE TYPE cat_color AS ENUM('#{Enum.join(@cat_colors, "','")}')"
  end
end
