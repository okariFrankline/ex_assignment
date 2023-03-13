defmodule ExAssignment.TodosTest do
  use ExAssignment.DataCase, async: false

  alias ExAssignment.Todos
  alias ExAssignment.Todos.Todo
  alias ExAssignment.Core.Todos.Cache

  describe "list todos" do
    setup [
      :create_open_todos,
      :create_closed_todos
    ]

    test "returns a list of open todos" do
      todos = Todos.list_todos(:open)
      assert Enum.all?(todos, &(&1.done == false))
    end

    test "returns a list of closed todos" do
      todos = Todos.list_todos(:done)
      assert Enum.all?(todos, &(&1.done == true))
    end

    test "returns a list of all the todos irregardless of their status" do
      todos = Todos.list_todos()
      assert Enum.all?(todos, &(&1.done in [true, false]))
    end
  end

  describe "create todo" do
    setup [
      :reset_cache
    ]

    test "successfully creates a new todo and inserts it into the recommendation cache if the cache is empty" do
      params = string_params_for(:todo, done: false)

      assert {:ok, %Todo{id: id}} = Todos.create_todo(params)
      assert %Todo{id: ^id} = Cache.get_recommended()
    end

    test "successfully creates a new todo but does not insert it into the recommendation cache, if the priority of the new todo is lower" do
      {:ok, %Todo{id: cached_todo_id}} =
        :todo
        |> string_params_for(done: false, priority: 2)
        |> Todos.create_todo()

      {:ok, %Todo{id: new_todo_id}} =
        :todo
        |> string_params_for(done: false, priority: 4)
        |> Todos.create_todo()

      %Todo{id: new_cached_id} = Cache.get_recommended()

      assert cached_todo_id != new_todo_id && new_cached_id == cached_todo_id
    end

    test "successfully creates a new todo and updates the recommendation cache if the priority of the new todo id higher than cached" do
      :todo
      |> string_params_for(done: false, priority: 10)
      |> Todos.create_todo()

      {:ok, %Todo{id: new_todo_id}} =
        :todo
        |> string_params_for(done: false, priority: 4)
        |> Todos.create_todo()

      %Todo{id: new_cached_id} = Cache.get_recommended()

      assert new_cached_id == new_todo_id
    end
  end

  describe "check todo" do
    setup [
      :reset_cache
    ]

    test "successfully marks a todo as checked" do
      {:ok, %Todo{id: id}} =
        :todo
        |> string_params_for(done: false)
        |> Todos.create_todo()

      assert {:ok, %Todo{id: ^id, done: true}} = Todos.check(id)
    end

    test "successfully marks a todo as done, and if it is the current recommended task, it updates the recommendation cache with a new task" do
      {:ok, %Todo{id: id}} =
        :todo
        |> string_params_for(done: false)
        |> Todos.create_todo()

      current_cached_todo = Cache.get_recommended()
      insert(:todo, done: false, priority: 10)

      {:ok, _} = Todos.check(id)
      new_cached_todo = Cache.get_recommended()

      refute current_cached_todo.id == new_cached_todo.id
    end

    test "successfully marks a todo as done, and if it's not the current recommended task, it does not update the recommendation cache" do
      :todo
      |> string_params_for(done: false)
      |> Todos.create_todo()

      current_cached_todo = Cache.get_recommended()
      to_update_todo = insert(:todo, done: false, priority: 10)

      {:ok, _} = Todos.check(to_update_todo.id)
      new_cached_todo = Cache.get_recommended()

      assert current_cached_todo.id == new_cached_todo.id
    end
  end

  describe "uncheck todo" do
    setup [
      :reset_cache
    ]

    test "successfully marks a todo as unchecked" do
      {:ok, %Todo{id: id}} =
        :todo
        |> string_params_for(done: true)
        |> Todos.create_todo()

      assert {:ok, %Todo{id: ^id, done: false}} = Todos.uncheck(id)
    end

    test "successfully marks a todo as not done, if it has the a higher priority than the current recommended task, it updates the recommendation cache with a newly undone task" do
      :todo
      |> string_params_for(done: false, priority: 10)
      |> Todos.create_todo()

      to_uncheck_todo = insert(:todo, done: true, priority: 5)

      {:ok, _} = Todos.uncheck(to_uncheck_todo.id)
      new_cached_todo = Cache.get_recommended()

      assert new_cached_todo.id == to_uncheck_todo.id
    end

    test "successfully marks a todo as not done, if it does not have a higher priority than the current recommended task, it does not update the recommendation cache" do
      :todo
      |> string_params_for(done: false, priority: 2)
      |> Todos.create_todo()

      old_cached_todo = Cache.get_recommended()
      to_update_todo = insert(:todo, done: true, priority: 10)

      {:ok, _} = Todos.check(to_update_todo.id)
      new_cached_todo = Cache.get_recommended()

      assert old_cached_todo.id == new_cached_todo.id && to_update_todo.id != new_cached_todo.id
    end
  end

  defp create_open_todos(_) do
    todos =
      for _ <- 1..3 do
        insert(:todo, done: false)
      end

    {:ok, open_todos: todos}
  end

  defp create_closed_todos(_) do
    todos =
      for _ <- 1..3 do
        insert(:todo, done: true)
      end

    {:ok, done_todos: todos}
  end

  defp reset_cache(_) do
    Cache.reset_cache()

    :ok
  end
end
