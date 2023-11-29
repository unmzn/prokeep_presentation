defmodule ProkeepPresentation.Repo do
  use Ecto.Repo,
    otp_app: :prokeep_presentation,
    adapter: Ecto.Adapters.Postgres
end
