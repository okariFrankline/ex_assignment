defmodule ExAssignment.Core.Todos.Cache do
  @moduledoc """
  A cache for storing the recommended task to be performed next by the user
  The cache is built using an :ets table that is started when the application first boots up
  """
  alias ExAssignment.Todos.Todo

  @cache :recommended_task

  @doc """
  Creates a new ets table to store the recommended task
  """
  @spec new() :: :recommended_task
  def new do
    :ets.new(@cache, [:set, :public, :named_table])
  end

  @doc """
  Reset the cache by deleting all entries within the table
  """
  @spec reset_cache() :: true
  def reset_cache, do: :ets.delete_all_objects(@cache)

  @doc """
  Inserts or updates the recommended task in the cache

  ## Examples
  iex> add_recommended(task)
  true
  """
  @spec add_recommended(task :: Todo.t()) :: true
  def add_recommended(%Todo{id: id} = task) do
    with true <- :ets.delete_all_objects(@cache) do
      :ets.insert(@cache, {id, task})
    end
  end

  @doc """
  Returns the recommended task stored in the cache

  ## Example
  iex> get_recommended()
  %Todo{} | nil

  """
  @spec get_recommended() :: task :: Todo.t() | nil
  def get_recommended do
    case :ets.tab2list(@cache) do
      [] -> nil
      [{_id, todo} | _] -> todo
    end
  end
end
