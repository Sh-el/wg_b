defmodule Wg.Animals.Cats.Statistic do
  @moduledoc """
  Defines the Ecto schema for storing cat statistics.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false

  schema "cats_stat" do
    field(:tail_length_mean, :decimal)
    field(:tail_length_median, :decimal)
    field(:tail_length_mode, {:array, :integer})
    field(:whiskers_length_mean, :decimal)
    field(:whiskers_length_median, :decimal)
    field(:whiskers_length_mode, {:array, :integer})
  end

  defp all_fields do
    __MODULE__.__schema__(:fields)
  end

  def changeset(cat, attrs) do
    cat
    |> cast(attrs, all_fields())
    |> validate_required(all_fields())
    |> validate_number(:tail_length_mean, greater_than_or_equal_to: 0)
    |> validate_number(:tail_length_median, greater_than_or_equal_to: 0)
    |> validate_number(:whiskers_length_mean, greater_than_or_equal_to: 0)
    |> validate_number(:whiskers_length_median, greater_than_or_equal_to: 0)
  end
end
