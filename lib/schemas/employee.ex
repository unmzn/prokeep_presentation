defmodule ProkeepPresentation.Schemas.Employee do
  alias ProkeepPresentation.Schemas.Shipyard
  use Ecto.Schema
  import Ecto.Changeset
  #alias ProkeepPresentation.Schemas.Starship
  @type t() :: %__MODULE__{}
  @type id() :: pos_integer()
  @type name() :: String.t()

  @required_attrs [
    :name
  ]

  @other_attrs [
    :inserted_at,
    :updated_at,
    :metadata,
    :assigned_shipyard_id
  ]

  schema "employees" do
    field :name, :string
    field :metadata, :map
    belongs_to :shipyard, Shipyard, foreign_key: :assigned_shipyard_id
    #has_many :starships, Starship
    #TODO: work order assignments
    timestamps()
  end

  def changeset(attrs) do
    %__MODULE__{}
    |> cast(attrs, @required_attrs ++ @other_attrs)
  end
end
