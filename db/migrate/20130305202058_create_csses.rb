class CreateCsses < ActiveRecord::Migration
  def self.up
    create_table :csses do |t|
      t.integer :size
      t.string :filename
      t.string :content_type
      t.references :game

      t.timestamps
    end
  end

  def self.down
    drop_table :csses
  end
end
