class CreateStandards < ActiveRecord::Migration[8.1]
  def change
    create_table :standards do |t|
      t.string :event_name
      t.string :organization
      t.string :standard_type
      t.float :target_time_seconds

      t.timestamps
    end
  end
end
