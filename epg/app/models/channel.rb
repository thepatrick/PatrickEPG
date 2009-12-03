class Channel < ActiveRecord::Base
  
  belongs_to :lineup
  belongs_to :station
  
end
