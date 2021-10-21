# frozen_string_literal: true

require 'json'
require 'httparty'
require 'active_support/time'

module Scrapers
  class BND
    def initialize(fund_id)
      uri = "https://devrobotapi.azurewebsites.net/roboadvisor/v1/fundrates?id=#{fund_id}"
      options = {
        headers: { 'User-Agent' => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2272.43 Safari/537.36' },
      }
      @json = JSON.parse(HTTParty.get(uri, options).body)
    end

    def quotation_history
      raise 'weird data' if @json['rates'].length < 50 || !@json['status'].nil?

      @json['rates'].map do |item|
        date = Time.parse(item['date']).to_date
        {
          date: date.strftime('%Y-%m-%d'),
          close: item['nav']
        }
      end
    end
  end
end
