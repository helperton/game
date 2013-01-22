require 'active_record'

class Models
  class Player < ActiveRecord::Base
    #attr_accessible :name, :password, :description, :room, :health
  end

  class Room < ActiveRecord::Base
    #attr_accessible :x, :y, :z, :description
  end
end
