# frozen_string_literal: true

require 'nokogiri'
require 'httparty'
require 'http-cookie'

module Scrapers
  class ASR
    def initialize(reference_date, verification_token, cookies_file)
      cookieJar = HTTP::CookieJar.new
      cookieJar.load(cookies_file, format = :cookiestxt)

      uri = "https://mijndoenpensioen.asr.nl/Belegging/Rekening"
      options = {
        headers: {
          'User-Agent' => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2272.43 Safari/537.36',
          'Cookie' => HTTP::Cookie.cookie_value(cookieJar.cookies)
        }
      }

      if verification_token.nil?
        # this is the first request, get today's table
        method = :get
      else
        method = :post
        options[:body] = {
          "__RequestVerificationToken" => verification_token,
          "ReferenceDate" => reference_date
        }
      end

      @doc = Nokogiri::HTML(HTTParty.send(method, uri, options).body, nil, 'UTF-8')
    end

    def investment_status
      {
        next_verification_token: verification_token,
        date: date,
        table_lines: table_lines,
      }
    end

    def date
      @doc.css('#ReferenceDate').attr('value').value
    end

    def verification_token
      @doc.css('input[name=__RequestVerificationToken]').attr('value').value
    end

    def table_lines
      result = []
      @doc.css('form[action="/Belegging/Rekening"] tbody tr').each do |tr|
        line = []
        tr.css('td').each do |td|
          content = td.content.gsub(/([\r\n\t ])+/, ' ').strip
          if content.match(/%$/)
            content = (content.sub(/%$/, '').to_r / 100)
            content = sprintf('%.4f', content)
          end
          if content.match(/^€\xC2\xA0/)
            content = content.sub(/^€\xC2\xA0/, '')
            content = content.sub(',', '')
          end
          line << content
        end
        result << line
      end
      result
    end
  end
end
