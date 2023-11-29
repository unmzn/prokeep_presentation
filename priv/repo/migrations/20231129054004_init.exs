defmodule ProkeepPresentation.Repo.Migrations.Init do
  use ProkeepPresentation.Migration

  def change do
    standard_table(:shipyards)

    standard_table :employees do
      add :assigned_shipyard_id, references(:shipyards)
    end

    standard_table :starships do
      add :shipyard_id, references(:shipyards)
    end

    create table(:work_orders) do
      add :title, :text, null: false
      add :description, :text, null: false
      add :metadata, :map, null: false, default: "{}"

      timestamps()
    end

    create table(:work_order_assignments) do
      add :metadata, :map, null: false, default: "{}"

      add :assigned_employee_id, references(:employees)
      add :work_order_id, references(:work_orders)
      timestamps()
    end

    create table(:work_orders_to_starships) do
      add :work_order_id, references(:work_orders)
      add :starship_id, references(:starships)
    end
  end
end
