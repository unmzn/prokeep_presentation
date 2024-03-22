redo_migration:
  mix ecto.rollback
  mix ecto.migrate

force_reset:
    psql -c 'DROP DATABASE prokeep_presentation WITH (FORCE);' || true
    just setup_db

setup_db:
    mix ecto.create
    mix ecto.migrate
    just seed
    just sql_seed

iex:
  iex -S mix

seed:
  mix run priv/repo/seeds.exs

marp:
  npx @marp-team/marp-cli@latest --html -w hackathon_slides.md

open_marp:
  open hackathon_slides.html

schema_gen:
  just --justfile "/Users/alexanderwebb/schema_spy/Justfile"

schema_docker:
  podman run -v "$PWD/output"
  
sql_seed:
  psql -d prokeep_presentation -a -f seed.sql

psql:
  psql -d prokeep_presentation
