
defmodule ProkeepPresentation.Schemas.WorkOrderAssignment do
  use Ecto.Schema
  import Ecto.Changeset
  alias ProkeepPresentation.Schemas.WorkOrder
  alias ProkeepPresentation.Schemas.Employee

  @type t() :: %__MODULE__{}
  @type id() :: pos_integer()
  @type name() :: String.t()

  @required_attrs []

  @other_attrs [
    :inserted_at,
    :updated_at,
    :metadata
  ]

  schema "work_order_assignments" do
    field :metadata, :map
    belongs_to :employee, Employee
    belongs_to :work_order, WorkOrder
  #alias Prok
    timestamps()
  end

  def changeset(attrs) do
    %__MODULE__{}
    |> cast(attrs, @required_attrs ++ @other_attrs)
  end
end
