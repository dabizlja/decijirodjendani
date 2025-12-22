class CreateTags < ActiveRecord::Migration[7.2]
  def change
    create_table :tags do |t|
      t.string :name, null: false
      t.string :icon
      t.string :color
      t.string :slug

      t.timestamps
    end

    add_index :tags, :name, unique: true
    add_index :tags, :slug, unique: true
  end
end
