class CreateImages < ActiveRecord::Migration
  def self.up
    create_table :images do |t|
      t.integer :size
      t.string :filename
      t.string :content_type
      t.references :game

      t.timestamps
    end
  end

  def self.down
    drop_table :images
  end
end
