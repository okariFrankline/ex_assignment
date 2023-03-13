defmodule ExAssignment.Queries.Todos do
  @moduledoc """
  Defines queries for working with Todos
  """

  import Ecto.Query, only: [where: 3, order_by: 3, limit: 2]

  alias ExAssignment.Todos.Todo

  @doc """
  Returns the base query for todos
  """
  @spec new() :: Ecto.Queryable.t()
  def new do
    Todo
    |> order_by([t], t.priority)
  end

  @doc """
  Returns a list of todos that have been marked as done

  ### Examples
  iex> completed()
  """
  @spec completed() :: Ecto.Query.t()
  @spec completed(query :: Ecto.Queryable.t()) :: Ecto.Query.t()
  def completed(query \\ new()) do
    query
    |> where([t], t.done == true)
  end

  @doc """
  Returns a list of todos that have not been marked as done

  ### Examples
  iex> not_completed()
  %Ecto.Query{}
  """
  @spec not_completed() :: Ecto.Query.t()
  @spec not_completed(query :: Ecto.Queryable.t()) :: Ecto.Query.t()
  def not_completed(query \\ new()) do
    query
    |> where([t], t.done == false)
  end

  @doc """
  Returns a list of todos which have a priority higher than the provided
  priority

  ## Examples
  iex> priority_higher_than(priority)
  %Ecto.Query{}
  """
  @spec priority_higher_than(query :: Ecto.Queryable.t(), priority :: pos_integer()) ::
          Ecto.Queryable.t()
  def priority_higher_than(query \\ new(), priority) do
    query
    |> where([t], t.priority >= ^priority)
  end

  @doc """
  Returns a query representing a todo identified by a given id
  """
  @spec with_id(query :: Ecto.Queryable.t(), todo_id :: pos_integer()) :: Ecto.Queryable.t()
  def with_id(query \\ new(), todo_id) do
    query
    |> where([t], t.id == ^todo_id)
    |> limit(1)
  end
end
