class Program < ActiveRecord::Base
  
  has_many :schedules, :dependent => :destroy
  has_many :genres, :dependent => :destroy
  has_many :production_crews, :dependent => :destroy
  
end
