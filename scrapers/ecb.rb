# frozen_string_literal: true

require 'json'
require 'httparty'
require 'active_support/time'
require 'tempfile'
require 'zip'

module Scrapers
  class ECB
    def initialize(symbol)
      @symbol = symbol
    end

    def quotation_history
      csv = CSV.new(fetch_document, col_sep: ',', row_sep: "\n")

      header = csv.first
      index = header.index(@symbol.upcase)

      results = csv.map do |i|
        next if i[index] == 'N/A'
        value = Rational(i[index])

        {
          date: i[0],
          close: value.to_f,
          inverted: (1/value).round(5).to_f
        }
      end

      results.compact
    end

    private

    def fetch_document
      if !Thread.current[:ecb_csv] || (Time.now.to_i - Thread.current[:ecb_updated_at]) >= 60 * 60
        Thread.current[:ecb_csv] = uncached_fetch_document
        Thread.current[:ecb_updated_at] = Time.now.to_i
      end
      Thread.current[:ecb_csv]
    end

    def uncached_fetch_document
      uri = 'https://www.ecb.europa.eu/stats/eurofxref/eurofxref-hist.zip'
      options = {
        headers: { 'User-Agent' => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2272.43 Safari/537.36' }
      }
      body = HTTParty.get(uri, options).body

      tmp = Tempfile.new('ecb')
      tmp.binmode
      tmp.write(body)
      zip = Zip::File.open(tmp.path)
      entry = zip.get_entry('eurofxref-hist.csv')
      doc = entry.get_input_stream.read
      zip.close
      tmp.close
      tmp.unlink

      doc
    end
  end
end
