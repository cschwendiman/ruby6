class CreateCodes < ActiveRecord::Migration
  def self.up
    create_table :codes do |t|
      t.integer :size
      t.string :filename
      t.string :content_type
      t.references :game

      t.timestamps
    end
  end

  def self.down
    drop_table :codes
  end
end
