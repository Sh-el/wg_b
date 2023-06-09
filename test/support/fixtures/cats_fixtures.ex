defmodule Wg.CatsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Wg.Cats` context.
  """

  @doc """
  Generate a cats list.
  """
  def cats_fixture(attrs_list \\ []) do
    cats =
      for attrs <- attrs_list do
        cat_fixture(attrs)
      end

    cats
  end

  @doc """
  Generate a cat.
  """
  def cat_fixture(attrs \\ %{}) do
    {:ok, cat} =
      attrs
      |> Enum.into(%{
        color: :black,
        name: "some name",
        tail_length: 12,
        whiskers_length: 15
      })
      |> Wg.Animals.Cats.create_cat()

    cat
  end
end
