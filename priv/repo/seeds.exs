# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Wg.Repo.insert!(%Wg.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Wg.Animals.{Cats, Cats.Cat}
alias Wg.Repo

Repo.transaction(fn ->
  Repo.delete_all(Cat)
end)

cats = [
  %{name: "Sss", color: :black, tail_length: 20, whiskers_length: 10},
  %{name: "Can", color: :white, tail_length: 25, whiskers_length: 15},
  %{name: "Man", color: :red, tail_length: 18, whiskers_length: 12},
  %{name: "Don", color: :black, tail_length: 22, whiskers_length: 12},
  %{name: "Tom", color: :"red & white", tail_length: 23, whiskers_length: 13},
  %{name: "Gun", color: :"red & black & white", tail_length: 24, whiskers_length: 13},
  %{name: "Good", color: :"red & black & white", tail_length: 14, whiskers_length: 5},
  %{name: "Boy", color: :black, tail_length: 23, whiskers_length: 7},
  %{name: "Rom", color: :"red & black & white", tail_length: 12, whiskers_length: 4},
  %{name: "Son", color: :black, tail_length: 2, whiskers_length: 1}
]

Repo.transaction(fn ->
  Enum.each(cats, fn cat -> Cats.create_cat(cat)
  end)
end)
