defmodule Wg.Repo.Migrations.CreateCatColorsInfo do
  use Ecto.Migration

  def change do
    create table(:cat_colors_info, primary_key: false) do
      add :color, :string, primary_key: true
      add :count, :integer
    end
  end
end
