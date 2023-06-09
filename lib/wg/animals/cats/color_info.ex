defmodule Wg.Animals.Cats.ColorInfo do
  @moduledoc """
  The `CatColorInfo` schema represents information about
  the number of cats in the system with each color.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @cat_colors [:black, :white, :red, :"black & white", :"red & white", :"red & black & white"]
  @primary_key {:color, Ecto.Enum, values: @cat_colors, autogenerate: false}

  schema "cat_colors_info" do
    field :count, :integer
  end

  defp all_fields do
    __MODULE__.__schema__(:fields)
  end

  @doc false
  def changeset(cat_color_info, attrs) do
    cat_color_info
    |> cast(attrs, all_fields())
    |> validate_required(all_fields())
  end
end
