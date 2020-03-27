# frozen_string_literal: true

require 'json'
require 'httparty'
require 'active_support/time'

module Scrapers
  class Eres
    def initialize(id)
      uri = "https://www.eres-group.com/eres/new_fiche_export.php?id=#{id}&format=CSV"
      options = {
        headers: { 'User-Agent' => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2272.43 Safari/537.36' }
      }
      @csv = CSV.parse(HTTParty.get(uri, options).body, col_sep: ';')
    end

    def quotation_history
      @csv.reverse.map do |r|
        {
          date: r[2],
          close: r[3].to_f
        }
      end
    end
  end
end
