defmodule ExAssignment.Todos do
  @moduledoc """
  Provides operations for working with todos.
  """

  import Ecto.Query, warn: false

  alias ExAssignment.Core
  alias ExAssignment.Repo
  alias ExAssignment.Todos.Todo
  alias ExAssignment.Queries.Todos

  @doc """
  Returns the list of todos, optionally filtered by the given type.

  ## Examples

      iex> list_todos(:open)
      [%Todo{}, ...]

      iex> list_todos(:done)
      [%Todo{}, ...]

      iex> list_todos()
      [%Todo{}, ...]

  """
  @spec list_todos(type :: nil | :done | :open, query :: Ecto.Queryable.t()) :: [Todo.t()]
  def list_todos(type \\ nil, query \\ Todos.new())

  def list_todos(:done, query) do
    query
    |> Todos.completed()
    |> Repo.all()
  end

  def list_todos(:open, query) do
    query
    |> Todos.not_completed()
    |> Repo.all()
  end

  def list_todos(_type, query) do
    query
    |> Repo.all()
  end

  @doc """
  Returns the next todo that is recommended to be done by the system.

  ASSIGNMENT: ...
  """
  defdelegate get_recommended, to: Core.Todos.Recommended, as: :fetch

  @doc """
  Gets a single todo.

  Raises `Ecto.NoResultsError` if the Todo does not exist.

  ## Examples

      iex> get_todo!(123)
      %Todo{}

      iex> get_todo!(456)
      ** (Ecto.NoResultsError)

  """
  def get_todo!(id), do: Repo.get!(Todo, id)

  @doc """
  Creates a todo.

  ## Examples

      iex> create_todo(%{field: value})
      {:ok, %Todo{}}

      iex> create_todo(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_todo(attrs :: map()) :: {:ok, Todo.t()} | {:error, Ecto.Changeset.t()}
  defdelegate create_todo(attrs), to: Core.Todos.Create, as: :execute

  @doc """
  Updates a todo.

  ## Examples

      iex> update_todo(todo, %{field: new_value})
      {:ok, %Todo{}}

      iex> update_todo(todo, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """

  @spec update_todo(todo_id :: pos_integer(), params :: map()) ::
          {:ok, Todo.t()} | {:error, Ecto.Changeset.t()}
  defdelegate update_todo(todo_id, params), to: Core.Todos.Update, as: :execute

  @doc """
  Deletes a todo.

  ## Examples

      iex> delete_todo(todo)
      {:ok, %Todo{}}

      iex> delete_todo(todo)
      {:error, %Ecto.Changeset{}}

  """
  def delete_todo(%Todo{} = todo) do
    Repo.delete(todo)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking todo changes.

  ## Examples

      iex> change_todo(todo)
      %Ecto.Changeset{data: %Todo{}}

  """
  def change_todo(%Todo{} = todo, attrs \\ %{}) do
    Todo.changeset(todo, attrs)
  end

  @doc """
  Marks the todo referenced by the given id as checked (done).

  ## Examples

      iex> check(1)
      :ok

  """

  # def check(id) do
  #   {_, _} =
  #     from(t in Todo, where: t.id == ^id, update: [set: [done: true]])
  #     |> Repo.update_all([])

  #   :ok
  # end

  @spec check(todo_id :: pos_integer(), action :: :done) ::
          {:ok, Todo.t()} | {:error, Ecto.Changeset.t()} | {:error, :task_not_found}
  defdelegate check(todo_id, action \\ :done), to: Core.Todos.Check, as: :execute

  @doc """
  Marks the todo referenced by the given id as unchecked (not done).

  ## Examples

      iex> uncheck(1)
      :ok

  """

  # def uncheck(id) do
  #   {_, _} =
  #     from(t in Todo, where: t.id == ^id, update: [set: [done: false]])
  #     |> Repo.update_all([])

  #   :ok
  # end

  @spec uncheck(todo_id :: pos_integer(), action :: :undone) ::
          {:ok, Todo.t()} | {:error, Ecto.Changeset.t()} | {:error, :task_not_found}
  defdelegate uncheck(todo_id, action \\ :undone), to: Core.Todos.Check, as: :execute
end
