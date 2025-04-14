class AddFileReferenceToProducts < ActiveRecord::Migration[7.1]
  def change
    add_reference :products, :file, null: false, foreign_key: true
  end
end
