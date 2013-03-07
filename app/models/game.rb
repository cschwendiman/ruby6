class Game < ActiveRecord::Base
  belongs_to :user
  has_many :players, :dependent => :destroy
  has_many :agents_games
  has_many :agents, :through => :agents_games
  has_many :results
  has_one :image, :dependent => :destroy
  has_one :css, :dependent => :destroy
  has_one :code, :dependent => :destroy
  has_one :template, :dependent => :destroy 
  validates_presence_of :name, :class_name
  serialize :saved
  
  cattr_reader :per_page
  @@per_page = 50

  def render_template(state)
    begin
      image_path = self.image.public_filename

      renderer = ERB.new(File.read(self.template.public_filename), 4)
      return renderer.result(binding.clone.taint)
    rescue Exception => e
      return "BAD TEMPLATE : #{e.message}"
    end
  end
end
