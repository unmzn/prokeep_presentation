defmodule ProkeepPresentation.Schemas.Shipyard do
  use Ecto.Schema
  import Ecto.Changeset
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

  schema "shipyards" do
    field :name, :string
    field :metadata, :map
    has_many :starships, Starship
    timestamps()
  end

  def changeset(attrs) do
    %__MODULE__{}
    |> cast(attrs, @required_attrs ++ @other_attrs)
  end
end
