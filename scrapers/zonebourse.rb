# frozen_string_literal: true

require 'json'
require 'httparty'
require 'active_support/time'

module Scrapers
  class Zonebourse
    def initialize(symbol)
      uri = "https://www.zonebourse.com/charting/atDataFeed.php?codeZB=#{symbol}&type=chart&fields=Date%2COpen%2CHigh%2CLow%2CClose"
      options = {
        headers: { 'User-Agent' => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2272.43 Safari/537.36' }
      }
      @json = JSON.parse(HTTParty.get(uri, options).body)
    end

    def quotation_history
      @json.reverse.map do |item|
        date = Time.at(item['x']/1000)
        {
          date: date.strftime('%Y-%m-%d'),
          close: item['close']
        }
      end
    end
  end
end
