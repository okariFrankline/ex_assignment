defmodule ExAssignment.Todos.Todo do
  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          title: String.t(),
          done: true | false,
          priority: pos_integer()
        }

  schema "todos" do
    field(:done, :boolean, default: false)
    field(:priority, :integer)
    field(:title, :string)

    timestamps()
  end

  @doc """
  Returns a changeset for creating new todos

  ## Examples

  iex> creation_changeset(todo, attrs)
  %Ecto.Changeset{}

  """
  @spec changeset(todo :: t | changeset, attrs :: map) :: changeset
        when changeset: Ecto.Changeset.t()
  def changeset(todo \\ %__MODULE__{}, attrs) do
    todo
    |> cast(attrs, [:title, :priority, :done])
    |> validate_required([:title, :priority, :done])
  end

  @doc """
  Returns a changeset for creating new todos

  ## Examples

  iex> creation_changeset(todo, attrs)
  %Ecto.Changeset{}

  """
  @spec creation_changeset(todo :: t | changeset, attrs :: map) :: changeset
        when changeset: Ecto.Changeset.t()
  def creation_changeset(todo \\ %__MODULE__{}, attrs) do
    todo
    |> cast(attrs, [:title, :priority, :done])
    |> validate_required([:title, :priority, :done])
  end
end
