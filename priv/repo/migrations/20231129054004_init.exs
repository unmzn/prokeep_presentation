defmodule ProkeepPresentation.Repo.Migrations.Init do
  use ProkeepPresentation.Migration

  def change do
    dbg("execution time")

    unique_name_table(:shipyards)

    unique_name_table :employees do
      add :assigned_shipyard_id, references(:shipyards)
    end

    unique_name_table :starships do
      add :shipyard_id, references(:shipyards)
    end

    base_table :work_orders do
      add :title, :text, null: false
      add :description, :text, null: false
    end

    # Want timestamps but not metadata
    create table(:work_order_assignments) do
      add :assigned_employee_id, references(:employees)
      add :work_order_id, references(:work_orders)
      timestamps()
    end

    create table(:work_orders_to_starships) do
      add :work_order_id, references(:work_orders)
      add :starship_id, references(:starships)
      timestamps()
    end
  end
end
