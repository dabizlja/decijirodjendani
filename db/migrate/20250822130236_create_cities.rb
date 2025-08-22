class CreateCities < ActiveRecord::Migration[7.2]
  def change
    create_table :cities do |t|
      t.string :name
      t.string :slug
      t.string :region
      t.boolean :active

      t.timestamps
    end
  end
end
