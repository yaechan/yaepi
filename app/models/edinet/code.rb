class Edinet::Code < ActiveRecord::Base
  def to_param
    return edinet_code#.parameterize
  end

  def self.find(key)
    return find_by_edinet_code(key)
  end
end
