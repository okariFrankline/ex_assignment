defmodule ExAssignment.Factory do
  @moduledoc false

  use ExMachina.Ecto, repo: ExAssignment.Repo

  alias ExAssignment.Todos.Todo

  @doc false
  def todo_factory do
    %Todo{
      priority: Enum.random(1..100),
      done: Enum.random([true, false]),
      title: Faker.Lorem.sentence(3..7)
    }
  end
end
