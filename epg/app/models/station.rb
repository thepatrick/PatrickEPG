class Station < ActiveRecord::Base
  
  has_many :channels
  has_many :schedules
  
end
