require 'yaml'
require 'net/http'
require 'uri'

module Epilog

  class HttpStorage

    def initialize
      @fragments = []
    end

    def commit(data)
      fragment = fragmentise(data)
      bundle(fragment)
      send if ready_to_send?
    end

    def fragmentise(data)
      data.delete(:stat)
      digest = data.delete(:digest)
      entry = { digest => data }

      return entry.to_yaml

    end

    def bundle(fragment)
      @fragments << fragment
    end

    def ready_to_send?
      true if @fragments.length > 5
    end

    def send
      filename = compress_and_write
      content = File.open(filename).read
      url = URI.parse("http://holmwood.id.au/")
      request = Net::HTTP::Put.new(content)
      response = Net::HTTP.new(url.host, url.port).start do |http| 
        http.request(request)
      end
    end


    def compress_and_write
      time = Time.now.strftime("%Y-%m-%dT%H:%M:%S%Z")
      filename = "/tmp/#{time}.gz"

      Zlib::GzipWriter.open(filename) do |file|
        file << @fragments.to_yaml
        file.close
      end

      return filename

    end

  end

end

