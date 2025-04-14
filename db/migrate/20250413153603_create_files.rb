class CreateFiles < ActiveRecord::Migration[7.1]
  def change
    create_table :files do |t|
      t.string :key, null: false
      t.string :filename, null: false
      t.string :content_type
      t.string :bucket
      t.bigint :byte_size, null: false
      t.text :metadata
      t.string :etag
      
      t.timestamps
    end
    
    add_index :files, :key, unique: true
    
    add_reference :products, :file, foreign_key: true, null: true
  end
end