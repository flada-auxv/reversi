class Array
  def find_all_index(val)
    result = []

    self.each_with_index do |a, i|
      _val = val

      case a
      when String
        _val = val.to_s
      when Symbol
        _val = val.to_sym
      end

      result << i if a == _val
    end

    return (result.empty? ? nil : result)
  end
end
