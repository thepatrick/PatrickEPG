class Lineup < ActiveRecord::Base
  
  has_many :channels, :dependent => :destroy
  
end
