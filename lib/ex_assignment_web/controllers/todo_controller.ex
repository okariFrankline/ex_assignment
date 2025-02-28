defmodule ExAssignmentWeb.TodoController do
  use ExAssignmentWeb, :controller

  alias ExAssignment.Todos
  alias ExAssignment.Todos.Todo

  def index(conn, _params) do
    open_todos = Todos.list_todos(:open)
    done_todos = Todos.list_todos(:done)
    recommended_todo = Todos.get_recommended()

    render(conn, :index,
      open_todos: open_todos,
      done_todos: done_todos,
      recommended_todo: recommended_todo
    )
  end

  def new(conn, _params) do
    changeset = Todos.change_todo(%Todo{})
    render(conn, :new, changeset: changeset)
  end

  def create(conn, %{"todo" => todo_params}) do
    case Todos.create_todo(todo_params) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "Todo created successfully.")
        |> redirect(to: ~p"/todos")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    todo = Todos.get_todo!(id)
    render(conn, :show, todo: todo)
  end

  def edit(conn, %{"id" => id}) do
    todo = Todos.get_todo!(id)
    changeset = Todos.change_todo(todo)
    render(conn, :edit, todo: todo, changeset: changeset)
  end

  def update(conn, %{"id" => id, "todo" => todo_params}) do
    case Todos.update_todo(id, todo_params) do
      {:ok, todo} ->
        conn
        |> put_flash(:info, "Todo updated successfully.")
        |> redirect(to: ~p"/todos/#{todo}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    with :ok <- Todos.delete_todo(id) do
      conn
      |> put_flash(:info, "Todo deleted successfully.")
      |> redirect(to: ~p"/todos")
    end
  end

  def check(conn, %{"id" => id}) do
    with {:ok, _} <- Todos.check(id) do
      conn
      |> redirect(to: ~p"/todos")
    end
  end

  def uncheck(conn, %{"id" => id}) do
    with {:ok, _} <- Todos.uncheck(id) do
      conn
      |> redirect(to: ~p"/todos")
    end
  end
end
