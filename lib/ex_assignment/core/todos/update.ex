defmodule ExAssignment.Core.Todos.Update do
  @moduledoc """
  Updates a given todo

  """

  alias ExAssignment.Core.Todos.Cache
  alias ExAssignment.Repo
  alias ExAssignment.Todos.Todo

  @typep id :: pos_integer() | String.t()

  @doc """
  Updates a given todo identified by the todo_id  with the provided params

  After a successful update, we check whether or not the update changed the
  priority of the todo.

  If so, we ensure we compare this to the already stored recommended todo in order
  to update our cache only if the updated todo's priority has been set to a higher one
  that the recommended one

  ## Examples

  iex> execute(todo_id, params)
  {:ok, %Todo{}}

  iex> execute(todo_id, params)
  {:error, %Ecto.Changeset{}}

  iex> execute(wrong_id, params)
  {:error, :todo_not_found}

  """
  @spec execute(todo_id :: id(), params :: map()) ::
          {:ok, Todo.t()} | {:error, Ecto.Changeset.t()}
  def execute(todo_id, params) do
    with {:ok, todo} <- fetch_todo(todo_id),
         {:ok, updated_todo} = result <- update_todo(todo, params) do
      if has_priority_changed?(todo, updated_todo) do
        updated_todo
        |> check_and_maybe_update_cache()
      end

      result
    end
  end

  defp fetch_todo(todo_id) do
    case Repo.get(Todo, todo_id) do
      nil -> {:error, :todo_not_found}
      todo -> {:ok, todo}
    end
  end

  defp update_todo(todo, params) do
    todo
    |> Todo.changeset(params)
    |> Repo.update()
  end

  defp has_priority_changed?(todo, updated_todo) do
    todo.priority != updated_todo.priority
  end

  defp check_and_maybe_update_cache(updated_todo) do
    if cached = Cache.get_recommended() do
      cached
      |> maybe_update_cache(updated_todo)
    end
  end

  defp maybe_update_cache(cached, updated) do
    if updated.priority < cached.priority do
      updated
      |> Cache.add_recommended()
    end
  end
end
