defmodule Wg.CatsTest do
  use Wg.DataCase
  import Ecto.Query, warn: false

  alias Wg.Animals.Cats

  describe "cats" do
    alias Wg.Animals.Cats.Cat

    import Wg.CatsFixtures

    @valid_cats [
      %{name: "Tihon", color: "red & white", tail_length: 15, whiskers_length: 12},
      %{name: "Masya", color: "black", tail_length: 10, whiskers_length: 8},
      %{name: "Pushok", color: "red", tail_length: 12, whiskers_length: 9},
      %{name: "Barsik", color: "red", tail_length: 14, whiskers_length: 11},
      %{name: "Sima", color: "white", tail_length: 8, whiskers_length: 7}
    ]

    test "list_cats/0 returns all cats" do
      cat = cat_fixture()
      assert Cats.list_cats() == [cat]
    end

    test "get_cats_by_params/1 valid request" do
      cats_fixture(@valid_cats)

      valid_attrs = %{"attribute" => "name", "order" => "asc", "offset" => 0, "limit" => 2}

      result = Cats.get_cats_by_params(valid_attrs)

      assert {:ok, cats} = result
      assert length(cats) == 2
      assert Enum.at(cats, 0).name == "Barsik"
      assert Enum.at(cats, 1).name == "Masya"

      valid_attrs = %{"offset" => 0, "limit" => 5}

      result = Cats.get_cats_by_params(valid_attrs)

      assert {:ok, cats} = result
      assert length(cats) == 5
      assert Enum.at(cats, 0).name == "Tihon"
      assert Enum.at(cats, 4).name == "Sima"

      valid_attrs = %{"attribute" => "name", "order" => "asc", "offset" => 1}

      result = Cats.get_cats_by_params(valid_attrs)

      assert {:ok, cats} = result
      assert length(cats) == 4
      assert Enum.at(cats, 0).name == "Masya"
      assert Enum.at(cats, 3).name == "Tihon"

      valid_attrs = %{"attribute" => "name", "order" => "asc", "limit" => 1}

      result = Cats.get_cats_by_params(valid_attrs)

      assert {:ok, cats} = result
      assert length(cats) == 1
      assert Enum.at(cats, 0).name == "Barsik"

      valid_attrs = %{"attribute" => "name", "order" => "desc"}

      result = Cats.get_cats_by_params(valid_attrs)

      assert {:ok, cats} = result
      assert length(cats) == 5
      assert Enum.at(cats, 0).name == "Tihon"
      assert Enum.at(cats, 4).name == "Barsik"
    end

    test "get_cats_by_params/1 with invalid data returns error changeset" do
      cats_fixture(@valid_cats)

      invalid_attrs = %{"invalid" => "name", "order" => "invalid", "offset" => -1, "limit" => 34}

      assert {:error,
              %Ecto.Changeset{
                errors: [
                  limit: {_limit, _},
                  offset: {_offset, _},
                  invalid_fields: {_invalid_fields, _},
                  order: {_order, _}
                ]
              }} = Cats.get_cats_by_params(invalid_attrs)
    end

    test "create_cat/1 with valid data creates a cat" do
      valid_attrs = %{name: "Tihon", color: :black, tail_length: 15, whiskers_length: 12}

      assert {:ok, %Cat{} = cat} = Cats.create_cat(valid_attrs)
      assert cat.color == :black
      assert cat.name == "Tihon"
      assert cat.tail_length == 15
      assert cat.whiskers_length == 12
    end

    test "create_cat/1 cat with a same name returns error changeset" do
      valid_attrs = %{name: "Tihon", color: :black, tail_length: 15, whiskers_length: 12}

      cat_fixture(valid_attrs)

      assert {:error, %Ecto.Changeset{errors: [name: {name, _}]}} = Cats.create_cat(valid_attrs)
      assert name == "has already been taken"
    end

    test "create_cat/1 with invalid data. Data has not all fields returns error changeset" do
      invalid_attrs = %{name: "Tihon", tail_length: 15, whiskers_length: 12}

      assert {:error, %Ecto.Changeset{errors: [color: {color, _}]}} = Cats.create_cat(invalid_attrs)
      assert color == "can't be blank"
    end

    test "create_cat/1 with invalid data returns error changeset" do
      invalid_attrs = %{name: nil, color: nil, tail_length: nil, whiskers_length: nil}

      assert {:error, %Ecto.Changeset{}} = Cats.create_cat(invalid_attrs)

      invalid_attrs = %{
        name: "apkefkpwkfpfkwekfefpkekfkwkfkkwpofkwkepkkjjkjjjkjjjjjjjjjjjjjkjjkewekw1",
        color: :blue,
        tail_length: -2,
        whiskers_length: 35
      }

      assert {:error,
              %Ecto.Changeset{
                errors: [
                  whiskers_length: {_whiskers_length, _},
                  tail_length: {_tail_length, _},
                  name: {_name, _},
                  name: {_name_length, _},
                  color: {_color, _}
                ]
              }} = Cats.create_cat(invalid_attrs)
    end
  end
end
