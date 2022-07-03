# frozen_string_literal: true

require 'json'
require 'httparty'
require 'active_support/time'

module Scrapers
  class Boursorama
    def initialize(symbol)
      uri = "https://www.boursorama.com/bourse/action/graph/ws/GetTicksEOD?symbol=#{symbol}&length=7300&period=0&guid="
      options = {
        headers: { 'User-Agent' => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2272.43 Safari/537.36' }
      }
      @json = JSON.parse(HTTParty.get(uri, options).body)
    end

    def quotation_history
      @json['d']['QuoteTab'].reverse.map do |item|
        # offset = Time.now.in_time_zone('Europe/Paris').hour < 1 ? 1 : 0
        offset = 0
        date = Date.new(1970, 1, 1).days_since(item['d'] + offset)
        {
          date: date.strftime('%Y-%m-%d'),
          close: item['c']
        }
      end
    end
  end
end
