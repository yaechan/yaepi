class Edinet::Code < ActiveRecord::Base
  def to_param
    return edinetCode#.parameterize
  end

  def self.find(key)
    return find_by_edinetCode(key)
  end
end
