Sequel.migration do
  change do
    create_table :photos do
      primary_key :id

      String :title

      jsonb :image_data, null: false

      Time :created_at, null: false
      Time :updated_at, null: false
    end
  end
end
