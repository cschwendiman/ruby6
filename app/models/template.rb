class Template < ActiveRecord::Base
	has_attachment :max_size => 500.kilobytes, :storage => :file_system, :path_prefix => 'user_code/templates'
  	belongs_to :game
end
