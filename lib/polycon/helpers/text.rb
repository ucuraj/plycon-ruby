module Polycon
  module Helpers
    class TextHelper
      def self.to_snake_case(string)
        string.gsub(/(.)([A-Za-z])/, '\1_\2')
      end

      def self.snake_to_spaced(string)
        string.gsub(/(_)/, ' ')
      end
    end
  end
end