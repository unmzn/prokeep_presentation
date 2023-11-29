defmodule ProkeepPresentation.Schemas.WorkOrder do
  use Ecto.Schema
  import Ecto.Changeset
  alias ProkeepPresentation.Schemas.WorkOrderAssignment
  alias ProkeepPresentation.Schemas.Starship

  @type t() :: %__MODULE__{}
  @type id() :: pos_integer()
  @type name() :: String.t()

  @required_attrs [
    :name
  ]

  @other_attrs [
    :inserted_at,
    :updated_at,
    :metadata
  ]

  schema "work_orders" do
    field :title, :string
    field :description, :map
    field :metadata, :map
    many_to_many :starships, Starship, join_through: WorkOrderAssignment
    timestamps()
  end

  def changeset(attrs) do
    %__MODULE__{}
    |> cast(attrs, @required_attrs ++ @other_attrs)
    |> validate_required(@required_attrs)
  end
end
