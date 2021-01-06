# frozen_string_literal: true

require 'json'
require 'httparty'
require 'active_support/time'

module Scrapers
  class Eres
    def initialize(id)
      uri = "https://www.eres-group.com/eres/new_fiche_json.php?id=#{id}"
      options = {
        headers: { 'User-Agent' => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2272.43 Safari/537.36' }
      }
      @json = JSON.parse(HTTParty.get(uri, options).body)
    end

    def quotation_history
      @json.reverse.map do |r|
        {
          date: r["d"],
          close: r["p"]
        }
      end
    end
  end
end
