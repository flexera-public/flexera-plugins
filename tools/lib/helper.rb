# this is a helper file for the DangerFile
class Helper

  # check if the rsc response can be parsed.
  def valid_json?(string)
    !!JSON.parse(string)
  rescue JSON::ParserError
    false
  end

  # find deep nested keys
  def nested_hash_value(obj,key)
    if obj.respond_to?(:key?) && obj.key?(key)
      obj[key]
    elsif obj.respond_to?(:each)
      r = nil
      obj.find{ |*a| r=nested_hash_value(a.last,key) }
      r
    end
  end

end
