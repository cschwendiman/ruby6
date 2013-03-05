class RemoveAttachmentFromGames < ActiveRecord::Migration
  def self.up
    remove_column :games, :size
    remove_column :games, :filename
    remove_column :games, :content_type
  end

  def self.down
    add_column :games, :content_type, :string
    add_column :games, :filename, :string
    add_column :games, :size, :integer
  end
end
