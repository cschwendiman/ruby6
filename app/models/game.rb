class Game < ActiveRecord::Base
  belongs_to :user
  has_many :players, :dependent => :destroy
  has_many :agents_games
  has_many :agents, :through => :agents_games
  has_many :results
  has_many :images, :dependent => :destroy
  has_one :css, :dependent => :destroy
  has_one :code, :dependent => :destroy
  has_one :template, :dependent => :destroy 
  validates_presence_of :name, :class_name
  serialize :saved
	
  cattr_reader :per_page
  @@per_page = 50
end
