class CreateBusinessInquiries < ActiveRecord::Migration[7.2]
  def change
    create_table :business_inquiries do |t|
      t.references :business, null: false, foreign_key: true
      t.string :inquiry_type
      t.string :contact_method

      t.timestamps
    end
  end
end
