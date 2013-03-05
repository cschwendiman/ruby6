class Image < ActiveRecord::Base
	has_attachment :max_size => 2.megabytes, :storage => :file_system, :path_prefix => 'public/user_images', :content_type => :image
	validates_as_attachment
 	belongs_to :game
end
