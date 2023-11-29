defmodule ProkeepPresentation.Migration do
  defmacro __using__(_opts) do
    quote do
      use Ecto.Migration

      # yes you totally can define a macro inside a macro and it "just works"
      defmacrop standard_fields() do
        quote do
          add :name, :text, null: false
          add :metadata, :map, null: false, default: "{}"
          timestamps()
        end
      end

      # Define a table with:
      # - JSON metadata
      # - timestamps
      # - unique name
      defmacrop standard_table(table_name) when is_atom(table_name) do
        quote do
          create table(unquote(table_name)) do
            standard_fields()
          end
          create unique_index(unquote(table_name), [:name]) 
        end
      end

      defmacrop standard_table(table_name, do: block) when is_atom(table_name) do
        quote do
          create table(unquote(table_name)) do
            standard_fields()
            unquote(block)
          end
          create unique_index(unquote(table_name), [:name]) 
        end
      end
    end
  end
end
