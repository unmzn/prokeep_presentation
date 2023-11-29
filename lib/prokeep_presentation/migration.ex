defmodule ProkeepPresentation.Migration do
  defmacro __using__(_opts) do
    dbg("module definition time")
    quote do
      use Ecto.Migration

      defmacrop base_fields() do
        quote do
          add :metadata, :map, null: false, default: "{}"
          timestamps()
        end
      end

      defmacrop base_table(table_name) do
        quote do
          create table(unquote(table_name)) do
            base_fields()
          end
        end
      end

      defmacrop base_table(table_name, do: block) do
        quote do
          create table(unquote(table_name)) do
            base_fields()
            unquote(block)
          end
        end
      end

      defmacrop unique_name_table(table_name) when is_atom(table_name) do
        quote do
          create table(unquote(table_name)) do
            base_fields()
            add :name, :text, null: false
          end
          create unique_index(unquote(table_name), [:name]) 
        end
      end

      defmacrop unique_name_table(table_name, do: block) when is_atom(table_name) do
        # We have to use more primitive forms here
        dbg("Expansion for table: " <> Atom.to_string(table_name))
        quote do
          create table(unquote(table_name)) do
            base_fields()
            add :name, :text, null: false
            unquote(block)
          end
          create unique_index(unquote(table_name), [:name]) 
        end
      end
    end
  end
end
