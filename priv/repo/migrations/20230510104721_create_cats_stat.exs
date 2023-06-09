defmodule Wg.Repo.Migrations.CreateCatsStat do
  use Ecto.Migration

  def change do
    create table(:cats_stat, primary_key: false) do
      add :tail_length_mean, :decimal
      add :tail_length_median, :decimal
      add :tail_length_mode, {:array, :integer}
      add :whiskers_length_mean, :decimal
      add :whiskers_length_median, :decimal
      add :whiskers_length_mode, {:array, :integer}
    end
  end
end
