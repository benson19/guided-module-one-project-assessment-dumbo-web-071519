class UserClothes < ActiveRecord::Migration[5.2]
  def change
    create_table :users_clothes do |t|
      t.string :users_clothes
      t.integer :user_id
      t.integer :clothing_id
    end
  end
end
