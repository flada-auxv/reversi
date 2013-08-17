class Array
  def find_all_index(val)
    self.each_with_index.with_object([]) do |(a, i), result|
      _val = val

      case a
      when String
        _val = val.to_s
      when Symbol
        _val = val.to_sym
      end

      result << i if a == _val
    end
  end
end
