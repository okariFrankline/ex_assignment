defmodule ExAssignment.Core.Todos.Recommended do
  @moduledoc """
  Returns the next recommended task to the user
  """

  alias ExAssignment.Repo
  alias ExAssignment.Todos.Todo
  alias ExAssignment.Queries.Todos
  alias ExAssignment.Core.Todos.Cache

  @doc """
  Returns the next recommended task

  The function first tries to fetch the recommended task from the cache
  where two can happen depending on whether or not the task is available or not

  1. If the task is found in the cache, we ensure that the recommended task is still
      of the highest priority in the db ( protects having a recently added todo that may
      have a higher priority than the one in the cache)

  2. If the task is not found in the cache, we check the db to fetch the recommended task and
      if found, we update the cache by adding the todo into the cache

  ## Examples

  iex> fetch()
  %Todo{} | nil
  """
  @spec fetch() :: Todo.t()
  def fetch do
    case Cache.get_recommended() do
      nil -> recommended_from_db()
      todo -> ensure_is_highest_priority(todo)
    end
  end

  defp recommended_from_db do
    query = Todos.not_completed()

    query
    |> do_recommended_from_db()
  end

  defp do_recommended_from_db(query) do
    case Repo.all(query) do
      [] -> nil
      todos -> sort_and_update_cache(todos)
    end
  end

  defp sort_and_update_cache(todos) do
    todos
    |> sort_by_priority()
    |> tap(&update_cache/1)
  end

  defp sort_by_priority(todos) do
    todos
    |> Enum.min_by(& &1.priority, fn -> nil end)
  end

  defp update_cache(todo) do
    with todo when not is_nil(todo) <- todo do
      Cache.add_recommended(todo)
    end
  end

  defp ensure_is_highest_priority(%Todo{priority: priority}) do
    priority
    |> Todos.priority_higher_than()
    |> do_recommended_from_db()
  end
end
