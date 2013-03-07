class Image < ActiveRecord::Base
  has_attachment :max_size => 2.megabytes, :storage => :file_system, :path_prefix => 'public/user_uploads', :partition => false, :content_type => :image, :partition =>false
  validates_as_attachment
  belongs_to :game

  def full_filename()
  	file_system_path = self.attachment_options[:path_prefix]
  	File.join(RAILS_ROOT, file_system_path, self.game_id.to_s, self.filename)
  end

  def public_filename()
  	File.join('/user_uploads', self.game_id.to_s, self.filename)
  end
end
