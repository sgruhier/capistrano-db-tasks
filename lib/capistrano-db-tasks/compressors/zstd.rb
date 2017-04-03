module Compressors
  class Zstd < Base
    COMPRESSOR_BIN = :zstd

    class << self
      def file_extension
        "zstd"
      end

      def compress(from, to = nil)
        level = 5
        from = from == :stdin ? "-" : from
        to = case to
             when '-'
               "-c --stdout"
             when nil
               ""
             else
               "-c --stdout > #{to}"
             end

        "#{COMPRESSOR_BIN} -#{level} #{from} #{to}"
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

        "#{COMPRESSOR_BIN} -d #{from} #{to}"
      end
    end
  end
end
