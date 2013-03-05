class Css < ActiveRecord::Base
	has_attachment :max_size => 500.kilobytes, :storage => :file_system, :path_prefix => 'public/user_stylesheets', :content_type => 'text/css'
  	validates_as_attachment
  	belongs_to :game
end
