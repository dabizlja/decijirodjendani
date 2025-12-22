class RemoveImagesFromBusinesses < ActiveRecord::Migration[7.2]
  def change
    remove_column :businesses, :images, :text
  end
end
