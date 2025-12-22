class CreateBusinessViews < ActiveRecord::Migration[7.2]
  def change
    create_table :business_views do |t|
      t.references :business, null: false, foreign_key: true
      t.string :ip_address
      t.text :user_agent
      t.string :referer

      t.timestamps
    end
  end
end
