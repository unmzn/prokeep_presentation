import Config

config :prokeep_presentation,
  ecto_repos: [ProkeepPresentation.Repo]

config :prokeep_presentation, ProkeepPresentation.Repo,
  database: "prokeep_presentation",
  username: "postgres",
  password: "postgres",
  hostname: "localhost"
