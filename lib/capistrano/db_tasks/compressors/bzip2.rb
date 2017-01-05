module Compressors
  class Bzip2 < Base
    class << self
      def file_extension
        "bz2"
      end

      def compress(from, to = nil)
        to = case to
             when "-"
               "-c --stdout"
             when nil
               ""
             else
               "-c --stdout > #{to}"
             end

        "bzip2 #{from} #{to}"
      end

      def decompress(from, to = nil)
        from = "-f #{from}" unless from == "-"

        to = case to
             when "-"
               "-c --stdout"
             when nil
               ""
             else
               "-c --stdout > #{to}"
             end

        "bunzip2 -f #{from} #{to}"
      end
    end
  end
end
