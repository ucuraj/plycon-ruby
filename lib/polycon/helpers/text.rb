module Text
  def self.included(base)
    base.send :include, TextBase
    base.extend TextBase
  end

  module TextBase
    def to_snake_case(string)
      string.gsub(/(.)([A-Z])/, '\1_\2')
    end

    def snake_to_spaced(string)
      string.gsub(/(_)/, ' ')
    end
  end
end
