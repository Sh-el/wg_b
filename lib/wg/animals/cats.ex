defmodule Wg.Animals.Cats do
  @moduledoc """
  The Cats context.
  """
  import Ecto.Query, warn: false
  alias Wg.Repo
  alias Wg.Stat
  alias Wg.Animals.Cats.{Cat, Request, ColorInfo, Statistic}

  @doc """
  Returns the list of cats.

  ## Examples

      iex> Wg.Animals.Cats.list_cats()
      [%Cat{}, ...]

  """
  def list_cats do
    Repo.all(Cat)
  end

  @doc """
  Numbers of cats.

  ## Examples

      iex> Wg.Animals.Cats.total_records_in_table
      27

  """
  def total_records_in_table do
    Cat
    |> select([c], count(c.name))
    |> Repo.one()
  end

  # 4
  @doc """
  Returns the list of cats by params.

  ## Examples

      iex> Wg.Animals.Cats.get_cats_by_params(good_params)
      {:ok, [%Cat{}, ...]}

      iex> Wg.Animals.Cats.get_cats_by_params(bad_params)
      {:error, %Ecto.Changeset{}}

  """
  def get_cats_by_params(params) when params == %{} do
    {:ok, Repo.all(Cat)}
  end

  def get_cats_by_params(params) do
    %Request{}
    |> Request.changeset(params)
    |> get_cats()
  end

  defp get_cats(%Ecto.Changeset{valid?: false} = changeset), do: {:error, changeset}

  defp get_cats(%Ecto.Changeset{changes: %{attribute: attribute, order: order}} = changeset) do
    ordering = [{order, attribute}]

    cats =
      Cat
      |> order_by(^ordering)
      |> offset_limit(changeset)
      |> Repo.all()

    {:ok, cats}
  end

  defp get_cats(%Ecto.Changeset{} = changeset) do
    cats =
      offset_limit(changeset)
      |> Repo.all()

    {:ok, cats}
  end

  defp offset_limit(query \\ Cat, changeset) do
    offset = Ecto.Changeset.get_change(changeset, :offset)
    limit = Ecto.Changeset.get_change(changeset, :limit)
    query
    |> offset(^offset)
    |> limit(^limit)
  end

  # 5
  @doc """
  Creates a cat.

  ## Examples

      iex> Wg.Animals.Cats.create_cat(%{field: value})
      {:ok, %Cat{}}

      iex> Wg.Animals.Cats.create_cat(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_cat(attrs \\ %{}) do
    %Cat{}
    |> Cat.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Creates a cat_color_info.

  ## Examples

      iex> Wg.Animals.Cats.create_color_info(%{field: value})
      {:ok, %CatColorInfo{}}

      iex> Wg.Animals.Cats.create_color_info(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_color_info(attrs \\ %{}) do
    %ColorInfo{}
    |> ColorInfo.changeset(attrs)
    |> Repo.insert()
  end

  # 1
  @doc """
  Counts the number of cats for each color and saves the result in the database table `cat_colors_info`.
  The function groups the `Cat` table by the `color` field.
  Selects the `color` and count of the `color` for each group using Ecto's query syntax.
  The resulting query is then executed, and the result is saved in the `cat_colors_info` table.

  ## Examples

      iex> Wg.Animals.Cats.count_cats_by_color
      :ok
  """
  @spec count_cats_by_color :: :ok | :error
  def count_cats_by_color do
    count_cats()
    |> insert_cat_counts()
  end

  @spec count_cats :: [ColorInfo]
  defp count_cats do
    Cat
    |> group_by([c], c.color)
    |> select([c], %{color: c.color, count: count(c.color)})
    |> Repo.all()
  end

  @spec insert_cat_counts([ColorInfo]) :: :ok | :error
  defp insert_cat_counts(count_cats) do
    Repo.delete_all(ColorInfo)
    insert_results = Enum.map(count_cats, &create_color_info/1)

    case Enum.find(insert_results, fn {result, _changeset} -> result == :error end) do
      nil ->
        :ok

      {:error, _changeset} ->
        :error
    end
  end

  @doc """
  Creates a cat_stat.

  ## Examples

      iex> Wg.Animals.Cats.create_cat_stat(%{field: value})
      {:ok, %CatStat{}}

      iex> Wg.Animals.Cats.create_cat_stat(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_statistic(attrs \\ %{}) do
    %Statistic{}
    |> Statistic.changeset(attrs)
    |> Repo.insert()
  end

  # 2
  @doc """
  Fetches a list of cats, calculates statistics on their tail and whiskers lengths.
  Creates a new record in the `CatsStat` table with these statistics.

  ## Examples

      iex> Wg.Animals.Cats.cats_stat
      :ok
  """
  @spec count_cats_statistic :: :ok | :error
  def count_cats_statistic() do
    list_cats()
    |> calculate_cats_statistic()
    |> insert_cats_statistic()
  end

  @spec calculate_cats_statistic([Cat]) :: :error | {:ok, map()}
  defp calculate_cats_statistic([]), do: {:ok, %{}}

  defp calculate_cats_statistic([_ | _] = cats) do
    with {:ok, tail_lengths} <- calc_lengths(cats, & &1.tail_length),
         {:ok, whiskers_lengths} <- calc_lengths(cats, & &1.whiskers_length),
         {:ok, tail_length_mean} <- Stat.mean(tail_lengths),
         {:ok, tail_length_median} <- Stat.median(tail_lengths),
         {:ok, tail_length_mode} <- Stat.mode(tail_lengths),
         {:ok, whiskers_length_mean} <- Stat.mean(whiskers_lengths),
         {:ok, whiskers_length_median} <- Stat.median(whiskers_lengths),
         {:ok, whiskers_length_mode} <- Stat.mode(whiskers_lengths) do
      {:ok,
       %{
         tail_length_mean: tail_length_mean,
         tail_length_median: tail_length_median,
         tail_length_mode: tail_length_mode,
         whiskers_length_mean: whiskers_length_mean,
         whiskers_length_median: whiskers_length_median,
         whiskers_length_mode: whiskers_length_mode
       }}
    end
  end

  @spec calc_lengths([Cat], fun()) :: {:ok, list} | :error
  def calc_lengths(cats, func) do
    case Enum.all?(cats, fn cat -> is_number(func.(cat)) end) do
      true ->
        {:ok, cats |> Enum.map(func)}

      false ->
        :error
    end
  end

  @spec insert_cats_statistic(:error | {:ok, map()}) :: :ok | :error
  defp insert_cats_statistic(:error), do: :error

  defp insert_cats_statistic({:ok, stat} = _data) do
    Repo.delete_all(Statistic)

    case create_statistic(stat) do
      {:ok, _changeset} ->
        :ok

      {:error, _} ->
        :error
    end
  end
end
