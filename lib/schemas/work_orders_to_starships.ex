defmodule ProkeepPresentation.Schemas.WorkOrdersToStarships do
  alias ProkeepPresentation.Schemas.WorkOrder
  alias ProkeepPresentation.Schemas.Starship
  use Ecto.Schema
  import Ecto.Changeset

  @type t() :: %__MODULE__{}
  @type id() :: pos_integer()
  @type name() :: String.t()

  @required_attrs [
    :starship_id,
    :work_order_id
  ]

  @other_attrs [
    :inserted_at,
    :updated_at,
    :metadata
  ]

  schema "work_order_assignments" do
    field :metadata, :map
    belongs_to :sharship, Starship
    belongs_to :work_order, WorkOrder
    timestamps()
  end

  def changeset(attrs) do
    %__MODULE__{}
    |> cast(attrs, @required_attrs ++ @other_attrs)
    |> validate_required(@required_attrs)
  end
end
