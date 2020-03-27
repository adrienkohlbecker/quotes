# frozen_string_literal: true

require 'json'
require 'httparty'
require 'active_support/time'

module Scrapers
  class BND
    def initialize(fund_id)
      uri = 'https://secure.brandnewday.nl/service/navvaluesforfund'
      body = {
        'sort' => '',
        'page' => 1,
        'pageSize' => 1000,
        'group' => '',
        'filter' => '',
        'fundId' => fund_id,
        'startDate' => '01-01-2010',
        'endDate' => Date.today.strftime('%d-%m-%Y')
      }
      options = {
        headers: { 'User-Agent' => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2272.43 Safari/537.36' },
        body: body
      }
      @json = JSON.parse(HTTParty.post(uri, options).body)
    end

    def quotation_history
      raise 'weird data' if @json['Total'] < 50 || !@json['Errors'].nil?

      @json['Data'].map do |item|
        date = Time.at(item['Date'].match(/.*\((\d+)\).*/)[1].to_i / 1000).to_date
        {
          date: date.strftime('%Y-%m-%d'),
          close: item['NavMember']
        }
      end
    end
  end
end
