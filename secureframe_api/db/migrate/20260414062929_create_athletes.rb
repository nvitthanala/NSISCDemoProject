class CreateAthletes < ActiveRecord::Migration[8.1]
  def change
    create_table :athletes do |t|
      t.string :first_name
      t.string :last_name
      t.string :team
      t.boolean :active

      t.timestamps
    end
  end
end
