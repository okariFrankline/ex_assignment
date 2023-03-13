defmodule ExAssignment.Core.Todos.Check do
  @moduledoc """
  Marks a task as done or not done based on the provided action
  """

  alias ExAssignment.Todos
  alias ExAssignment.Todos.Todo
  alias ExAssignment.Core.Todos.Cache
  alias ExAssignment.Repo

  @doc """
  Marks a todo with the given id as done or not done based on the action specified

  Upon successful update of the todo, we check to ensure whether or this update affects
  the cached recommended item.

  If the item to be updated is the same as the cached recommended item, we recommend a new todo
  and if not the same, we check whether or not the action is for marking it as undone.

  If the action is for undone, we ensure that the undone item has or does not have a higher priority
  than what is currently recommended. Based on this, we update the cached recommendation based on the
  undone todo

  ## Examples

  iex> execute(todo_id, action)
  {:ok, %Todo{}}

  iex> execute(todo_id, action)
  {:error, %Ecto.Changeset{}}

  iex> execute(wrong_id, action)
  {:error, :todo_not_found}

  """
  @spec execute(todo_id :: pos_integer(), action :: :done | :undone) ::
          {:ok, Todo.t()} | {:error, Ecto.Changeset.t()}
  def execute(todo_id, action) do
    with {:ok, todo} <- fetch_todo(todo_id),
         {:ok, updated_todo} = result <- update_todo(todo, action) do
      updated_todo
      |> tap(&check_and_maybe_update_cache(&1, action))

      result
    end
  end

  defp fetch_todo(todo_id) do
    case Repo.get(Todo, todo_id) do
      nil -> {:error, :todo_not_found}
      todo -> {:ok, todo}
    end
  end

  defp update_todo(todo, action) do
    change = if action == :done, do: true, else: false

    todo
    |> Todo.changeset(%{done: change})
    |> Repo.update()
  end

  defp check_and_maybe_update_cache(todo, action) do
    case Cache.get_recommended() do
      nil -> nil
      cached -> maybe_update_cache(cached, todo, action)
    end
  end

  defp maybe_update_cache(%Todo{id: id} = _cached, %Todo{id: id} = _updated, action) do
    # because the cached item and the updated todo are the same, and the
    # action is :done, we recommend a new todo that will be updated in the cache.
    # However, if the action is to make it as undone, we do not do anything (we do not expect
    # a user to be able to mark a recommended task as undone as they are alway open)
    case action do
      :undone -> nil
      :done -> recommend_new_todo()
    end
  end

  defp maybe_update_cache(%Todo{} = cached, %Todo{} = updated, action) do
    # if the cached item and the item to be updated are not the same, we only
    # update the cache if the action is :undone, simply because the priority
    # for the newly opened item may be higher than that in the cache, hence the
    # need to maybe update the cache
    case action do
      :done -> nil
      _ -> check_priorities_and_maybe_update_cache(cached, updated)
    end
  end

  defp recommend_new_todo do
    with true <- Cache.reset_cache(), do: Todos.get_recommended()
  end

  defp check_priorities_and_maybe_update_cache(cached, updated) do
    if updated.priority < cached.priority do
      Cache.add_recommended(updated)
    end
  end
end
