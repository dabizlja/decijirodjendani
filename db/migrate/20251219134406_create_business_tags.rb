class CreateBusinessTags < ActiveRecord::Migration[7.2]
  def change
    create_table :business_tags do |t|
      t.references :business, null: false, foreign_key: true
      t.references :tag, null: false, foreign_key: true

      t.timestamps
    end
  end
end
