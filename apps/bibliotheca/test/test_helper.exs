ExUnit.start

Mix.Task.run "ecto.create", ~w(-r Bibliotheca.Repo --quiet)
Mix.Task.run "ecto.migrate", ~w(-r Bibliotheca.Repo --quiet)
Ecto.Adapters.SQL.begin_test_transaction(Bibliotheca.Repo)

