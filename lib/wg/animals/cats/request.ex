defmodule Wg.Animals.Cats.Request do
  @moduledoc """
  Cat request schema

  This module defines the Ecto schema for a cat list request. The request can be filtered and ordered by several attributes:

  - :name: the name of the cat.
  - :color: the color of the cat.
  - :tail_length: the length of the cat's tail.
  - :whiskers_length: the length of the cat's whiskers.

  The request can also include an `:offset` and a `:limit` parameter, to paginate the result.

  ### Example

  iex> request = %{"attribute" => "name", "order" => "asc", "limit" => 10, "offset" => 20}
  iex> Wg.Cats.get_cats_by_params(request)
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias Wg.Animals.Cats

  @allowed_attributes [:name, :color, :tail_length, :whiskers_length]
  @allowed_orders [:asc, :desc]

  @primary_key false

  schema "cats_list_request" do
    field(:attribute, Ecto.Enum, values: @allowed_attributes)
    field(:order, Ecto.Enum, values: @allowed_orders)
    field(:offset, :integer)
    field(:limit, :integer)
  end

  defp all_fields do
    __MODULE__.__schema__(:fields)
  end

  @doc false
  def changeset(cat_request, attrs) do
    total_records_in_table = Cats.total_records_in_table()

    cat_request
    |> cast(attrs, all_fields())
    |> validate_params_keys(attrs)
    |> validate_number(:offset,
      greater_than_or_equal_to: 0,
      less_than: total_records_in_table,
      message: "must be greater or equal to 0 or less than #{total_records_in_table}"
    )
    |> validate_number(:limit,
      greater_than_or_equal_to: 0,
      less_than_or_equal_to: total_records_in_table,
      message: "must be greater or equal to 0 or less or equal to #{total_records_in_table}"
    )
  end

  defp validate_params_keys(changeset, attrs) do
    allowed_keys = all_fields() |> Enum.map(&Atom.to_string(&1))
    invalid_keys = Map.keys(attrs) -- allowed_keys

    case invalid_keys do
      [] ->
        changeset

      _ ->
        add_error(changeset, :invalid_fields, "Invalid fields: #{inspect(invalid_keys)}")
    end
  end
end
