class Location
  def initialize(attributes)
    @attributes = attributes
  end

  def method_missing(method_name, *args)
    @attributes[method_name.to_s]
  end
end
