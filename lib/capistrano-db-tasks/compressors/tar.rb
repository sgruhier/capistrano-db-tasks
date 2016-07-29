module Compressors
  class Tar < Base

    class << self
      def file_extension
        "tar.gz"
      end

      def compress(from)
        "tar -zcvf #{from}.#{file_extension} #{from}/"
      end

      def decompress(from)
        "tar -zxvf #{from}"
      end
    end
  end
end
