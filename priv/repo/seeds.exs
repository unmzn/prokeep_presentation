alias ProkeepPresentation.Repo
alias ProkeepPresentation.Schemas.Shipyard
alias ProkeepPresentation.Schemas.Starship
alias ProkeepPresentation.Schemas.Employee

add_timestamps = fn maps ->
  maps
  |> Enum.map(fn map ->
    map
    |> Map.put(:inserted_at, NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second))
    |> Map.put(:updated_at, NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second))
  end)
end

make_shipyards = fn (names_list) ->
  names_list
  |> Enum.map(fn name ->
    %{
      name: name
    }
  end)
 |> add_timestamps.()
end

shipyard_names = [
  "EARTH L2 PRIME",
  "LUNAR SOUTH POLE",
  "EARTH LEO D-7",
  "EARTH GEO B-1"
]

make_starships = fn (names_list) ->
  names_list
  |> Enum.map(fn name ->
    %{
      name: name
    }
  end)
  |> add_timestamps.()
end


Repo.insert_all(Shipyard, make_shipyards.(shipyard_names))
Repo.insert_all(Starship, [
  %{
    name: "PS Jolly Roger",
    shipyard_id: 1,
    metadata: %{
      status: "DAMAGED"
    }
  },
  %{
    name: "SMS Enterprising",
  },
  %{
    name: "FS Hermes"
  },
  %{
    name: "CV Elephant",
    shipyard_id: 4
  },
] |> add_timestamps.())

Repo.insert_all(Employee, [
  %{
    name: "Bob Jones",
    assigned_shipyard_id: 1
  },
  %{
    name: "Jane Doe",
    assigned_shipyard_id: 4
  },
  %{
    name: "XP-7009",
    assigned_shipyard_id: 1
  }
] |> add_timestamps.())
