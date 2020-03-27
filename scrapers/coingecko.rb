# frozen_string_literal: true

require 'json'
require 'httparty'
require 'active_support/time'

module Scrapers
  class Coingecko
    def initialize(chart)
      uri = "https://www.coingecko.com/price_charts/#{chart}/eur/max.json?locale=en"
      options = {
        headers: { 'User-Agent' => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2272.43 Safari/537.36' }
      }
      @json = JSON.parse(HTTParty.get(uri, options).body)
    end

    def quotation_history
      @json['stats'].reverse.map do |item|
        date = Time.at(item[0] / 1000).to_date
        {
          date: date.strftime('%Y-%m-%d'),
          close: item[1] / 1000 # we work in micro-currency units (mBTC, mETH)
        }
      end
    end
  end
end
