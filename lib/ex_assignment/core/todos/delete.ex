defmodule ExAssignment.Core.Todos.Delete do
  @moduledoc """
  Allows for the deletion of a given todo
  """
  import Ecto.Query, only: [where: 3]

  alias ExAssignment.Repo
  alias ExAssignment.Todos
  alias ExAssignment.Todos.Todo
  alias ExAssignment.Core.Todos.Cache

  @spec execute(todo_id :: pos_integer()) :: {:ok, Todo.t()} | :ok
  def execute(todo_id) do
    with {:ok, _} <- maybe_delete_todo(todo_id) do
      todo_id
      |> tap(&check_and_maybe_update_cache/1)

      :ok
    end
  end

  defp maybe_delete_todo(todo_id) do
    deleted =
      Todo
      |> where([t], t.id == ^todo_id)
      |> Repo.delete_all([])

    {:ok, deleted}
  end

  defp check_and_maybe_update_cache(todo_id) do
    case Cache.get_recommended() do
      nil -> nil
      cached -> maybe_update_cache(cached, todo_id)
    end
  end

  defp maybe_update_cache(%Todo{id: cached_id} = _cached, todo_id) do
    # here, because the cached item's id and the todo that has already been delete are
    # the same, we are going to recommend a new todo since, this one has been deleted
    # and if the deleted todo is not the one cached, we do nothing
    cond do
      cached_id == todo_id -> recommend_new_todo()
      true -> nil
    end
  end

  defp recommend_new_todo do
    with true <- Cache.reset_cache(), do: Todos.get_recommended()
  end
end
