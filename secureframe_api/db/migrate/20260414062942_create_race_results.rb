class CreateRaceResults < ActiveRecord::Migration[8.1]
  def change
    create_table :race_results do |t|
      t.references :athlete, null: false, foreign_key: true
      t.string :event_name
      t.float :time_seconds
      t.date :date_swum
      t.string :round
      t.integer :placement
      t.boolean :made_a_final
      t.boolean :made_b_final
      t.string :ncaa_status

      t.timestamps
    end
  end
end
