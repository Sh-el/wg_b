defmodule Wg.Stat do
  @moduledoc """
  Provides statistical functions for calculating the mean, median, and mode of a list of numbers.
  """

  @doc """
  Calculates the mean (average) value of a list of numbers.

  ## Examples

      iex> Wg.Stat.mean([1, 2, 3])
      {:ok, 2.0}

      iex> Wg.Stat.mean([1, "error", 3])
      :error

      iex> Wg.Stat.mean([])
      :error

      iex> Wg.Stat.mean(:error)
      :error
  """
  @spec mean([number]) :: {:ok, float()} | :error
  def mean(list) do
    list
    |> validate_list()
    |> calculate_statistic(&do_mean/1)
  end

  defp do_mean(list), do: calculate_mean(list, 0, 0)

  defp calculate_mean([], sum, length), do: sum / length

  defp calculate_mean([head | tail], sum, length) do
    calculate_mean(tail, sum + head, length + 1)
  end

  @doc """
  Calculates the median of a list of numbers.

  Examples:

      iex> Wg.Stat.median([3, 1, 2])
      {:ok, 2}

      iex> Wg.Stat.median([3, 1, 2, 5])
      {:ok, 2.5}

      iex> Wg.Stat.median([1, -4, -1, -1, 1, -3])
      {:ok, -1.0}

      iex> Wg.Stat.median([])
      :error

      iex> Wg.Stat.median([:error])
      :error

      iex> Wg.Stat.median(:error)
      :error
  """
  @spec median([number]) :: {:ok, number} | :error
  def median(list) do
    list
    |> validate_list()
    |> calculate_statistic(&do_median/1)
  end

  @spec do_median([number]) :: number
  defp do_median(list) do
    midpoint =
      (length(list) / 2)
      |> Float.floor()
      |> round()

    {left, right} =
      Enum.sort(list)
      |> Enum.split(midpoint)

    case length(right) > length(left) do
      true ->
        [median | _] = right
        median

      false ->
        [first | _] = right
        [second | _] = Enum.reverse(left)
        do_mean([first, second])
    end
  end

  @doc """
  Calculates the mode(s) of a given list of numbers.

  ## Examples

      iex> Wg.Stat.mode([1, 2, 2, 2, 3, 3, 3])
      {:ok, [2, 3]}

      iex> Wg.Stat.mode([1, 2, 3])
      {:ok, [1, 2, 3]}

      iex> Wg.Stat.mode([1, 2, 2, 3, 3, 3])
      {:ok, [3]}

      iex> Wg.Stat.mode([])
      :error

      iex> Wg.Stat.mode([:error])
      :error

      iex> Wg.Stat.mode(:error)
      :error
  """
  @spec mode([number]) :: {:ok, [integer()]} | :error
  def mode(list) do
    list
    |> validate_list()
    |> calculate_statistic(&do_mode/1)
  end

  @spec do_mode([number]) :: [integer()]
  defp do_mode(list) do
    frequencies = frequencies(list)

    max_frequency =
      Map.values(frequencies)
      |> Enum.max()

    frequencies
    |> Enum.filter(fn {_number, frequency} -> frequency == max_frequency end)
    |> Enum.map(fn {number, _frequency} -> number end)
  end

  @spec frequencies([number]) :: map
  defp frequencies(list) do
    list
    |> Enum.reduce(%{}, fn tag, acc -> Map.update(acc, tag, 1, &(&1 + 1)) end)
  end

  defp validate_list([_ | _] = list) do
    case Enum.all?(list, &is_number/1) do
      true -> {:ok, list}
      false -> :error
    end
  end

  defp validate_list(_), do: :error

  defp calculate_statistic({:ok, list}, fun) do
    {:ok, fun.(list)}
  end

  defp calculate_statistic(:error, _), do: :error
end
