defmodule Wg.Animals.Cats.Cat do
  @moduledoc """
  Defines the `Wg.Cats.Cat` schema for Ecto.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @cat_colors [:black, :white, :red, :"black & white", :"red & white", :"red & black & white"]
  @primary_key {:name, :string, autogenerate: false}

  schema "cats" do
    field(:color, Ecto.Enum, values: @cat_colors)
    field(:tail_length, :integer)
    field(:whiskers_length, :integer)
  end

  defp all_fields do
    __MODULE__.__schema__(:fields)
  end

  @doc false
  def changeset(cat, attrs) do
    cat
    |> cast(attrs, all_fields())
    |> validate_required(all_fields())
    |> unique_constraint(:name, name: :cats_pkey)
    |> validate_length(:name,
      min: 2,
      max: 50,
      message: "should be at least 2 characters or at most 50 characters"
    )
    |> validate_format(:name, ~r/^[a-zA-Z\s]+$/, message: "only letters of the Latin alphabet")
    |> validate_number(:tail_length,
      greater_than_or_equal_to: 0,
      less_than: 30,
      message: "must be greater or equal to 0 or less than 30"
    )
    |> validate_number(:whiskers_length,
      greater_than_or_equal_to: 0,
      less_than: 30,
      message: "must be greater or equal to 0 or less than 30"
    )
  end
end
