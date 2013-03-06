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
  
  attr_accessor :code, :css, :template, :image
  
  def update_attachments
    conditions = ["game_id = ?", self.id]
    self.code = Code.find(:first, :conditions =>conditions)
    self.template = Template.find(:first, :conditions =>conditions)
    self.image = Image.find(:first, :conditions =>conditions)
    self.css = Css.find(:first, :conditions =>conditions)
    nil
  end
  
  cattr_reader :per_page
  @@per_page = 50
end
