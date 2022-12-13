# frozen_string_literal: true

require 'json'
require 'httparty'
require 'active_support/time'

module Scrapers
  class Eres
    def initialize(id)
      uri = 'https://core.communicate.airfund.io/api/v1/navs-evolution-chart/data'
      options = {
        headers: { 'User-Agent' => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2272.43 Safari/537.36', 'Content-Type' => 'application/json' },
        body: '{"locale":"fr","sId":"41481ca4-919c-46c0-9ca1-41a880ff4e8e","isinCode":"'+id+'","maxPeriodCode":"inception","debug":null,"displayBenchmark":true}'
      }
      @json = JSON.parse(HTTParty.post(uri, options).body)
    end

    def quotation_history
      @json["navs"].reverse.map do |r|
        {
          date: r["date"],
          close: r["value"]
        }
      end
    end
  end
end
