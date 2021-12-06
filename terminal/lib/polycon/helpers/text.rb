module Polycon
  module Helpers
    class TextHelper
      def self.to_snake_case(string)
        string.gsub(/(.)([A-Z])/, '\1_\2')
      end

      def self.snake_to_spaced(string)
        string.gsub(/(_)/, ' ')
      end

      def self.bar
        a = [[1.23, 5, :bagels], [3.14, 7, :gravel], [8.33, 11, :saturn]]
        '-' * (a[0][0].to_s.length + 4 + a[0][1].to_s.length + 3 + a[0][2].to_s.length + 5)
      end
    end
  end
end