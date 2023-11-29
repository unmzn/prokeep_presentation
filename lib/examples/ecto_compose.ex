defmodule ProkeepPresentation.Examples.EctoCompose do
  import Ecto.Query

  alias ProkeepPresentation.Schemas.Shipyard
  alias ProkeepPresentation.Schemas.Employee

  def all_shipyard_names() do
    from s in Shipyard,
      as: :shipyard,
      select: %{shipyard_name: as(:shipyard).name}
  end

  def shipyards_name_match(substring) do
    match_string = "%#{substring}%"
    from shipyard in Shipyard,
      as: :shipyard,
      where: ilike(shipyard.name, ^match_string),
      select: %{shipyard_name: as(:shipyard).name}
  end

  def with_employees(query) do
    from query,
      join: employee in Employee,
      as: :employee,
      on: employee.assigned_shipyard_id == as(:shipyard).id,
      select_merge: %{employee_name: as(:employee).name}
  end

  def with_assignment_count(query) do
    from query,
      join: "work_order_assignments",
      as: :woa,
      on: as(:employee).id == as(:woa).assigned_employee_id,
      group_by: [as(:shipyard).name, as(:employee).name],
      select_merge: %{assignment_count: count()}
  end

  def all_together(shipyard_name_substring) do
    shipyards_name_match(shipyard_name_substring)
    |> with_employees()
    |> with_assignment_count()
  end
end
