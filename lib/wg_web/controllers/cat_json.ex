defmodule WgWeb.CatJSON do
  alias Wg.Animals.Cats.Cat

  @doc """
  Renders a list of cats.
  """
  def index(%{cats: cats}) do
    for(cat <- cats, do: data(cat))
  end

  @doc """
  Renders a single cat.
  """
  def show(%{cat: cat}) do
    %{data: data(cat)}
  end

  defp data(%Cat{} = cat) do
    %{
      name: cat.name,
      color: cat.color,
      tail_length: cat.tail_length,
      whiskers_length: cat.whiskers_length
    }
  end
end
