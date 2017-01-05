module Compressors
  class Gzip < Base
    class << self
      def file_extension
        "gz"
      end

      def compress(from, to = nil)
        from = from == :stdin ? "-" : from
        to = case to
             when '-'
               "-c --stdout"
             when nil
               ""
             else
               "-c --stdout > #{to}"
             end

        "gzip #{from} #{to}"
      end

      def decompress(from, to = nil)
        from = from == :stdin ? "-" : from
        to = case to
             when :stdout
               "-c --stdout"
             when nil
               ""
             else
               "-c --stdout > #{to}"
             end

        "gzip -d #{from} #{to}"
      end
    end
  end
end
