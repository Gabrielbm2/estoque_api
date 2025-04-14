class RenameFilesToFileImages < ActiveRecord::Migration[7.1]
  def change
    rename_table :files, :file_images
    rename_column :products, :file_image_id, :file_image_id
  end
end