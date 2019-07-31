class Clothing < ActiveRecord::Migration[5.2]
  def change
    create_table :clothings do |t|
      t.string :clothes
      t.string :name
    end
  end
end