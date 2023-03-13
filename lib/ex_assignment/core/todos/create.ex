defmodule ExAssignment.Core.Todos.Create do
  @moduledoc """
  Creates a new todo within the system
  """

  alias ExAssignment.Repo
  alias ExAssignment.Todos.Todo
  alias ExAssignment.Core.Todos.Cache

  @doc """
  Creates a new todo

  Upon successful creation of a new todo, we check to ensure whether or not that
  new task has a higher priority than the one currently stored in the cache

  If the new task has a higher priority than the one currently in the cache, we update the
  cache and if not, we do nothing

  ## Example

  iex> execute(params)
  {:ok, %Todo{}} | {:error, %Ecto.Changeset{}}

  """
  @spec execute(params :: map()) :: {:ok, Todo.t()} | {:error, Ecto.Changeset.t()}
  def execute(params) do
    with {:ok, todo} = result <- create_new_todo(params) do
      todo
      |> tap(&check_and_maybe_update_cache/1)

      result
    end
  end

  defp create_new_todo(params) do
    params
    |> Todo.creation_changeset()
    |> Repo.insert()
  end

  defp check_and_maybe_update_cache(%Todo{} = todo) do
    case Cache.get_recommended() do
      nil -> add_to_cache(todo)
      cached -> compare_and_maybe_update_cache(todo, cached)
    end
  end

  defp compare_and_maybe_update_cache(new_todo, cached) do
    if new_todo.priority < cached.priority do
      add_to_cache(new_todo)
    end
  end

  defp add_to_cache(todo), do: Cache.add_recommended(todo)
end
