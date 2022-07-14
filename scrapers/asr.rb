# frozen_string_literal: true

require 'nokogiri'
require 'httparty'
require 'http-cookie'

module Scrapers
  class ASR
    # Downloads a single day's ASR pension statement table by parsing the page's HTML.
    #
    # This was built to execute within a single HTTP request,
    # and so no persistence of cookies or data, nor of the instantiated instance is assumed.
    #
    # It requires a file handle to "cookies.txt", which is exported from your browser.
    # I use https://github.com/lennonhill/cookies-txt immediately after authenticating to ASR
    # Remember that auth cookies expire over time so you need to do this each time
    # before using the scraper.
    # Please be careful with this file as it contains authentication material for your pension.
    #
    # Usage:
    # ======
    # Downloads the latest statement, which defaults to today:
    #   today = Scrapers::ASR.new(nil, nil, File.open('cookies.txt')).investment_status
    #
    #   => { date: '10-06-2022', next_verification_token: 'xxx', table_lines: [...] }
    #
    # Once that is done, the response contains the csrf token to use for the next arbitrary date request:
    #   yesterday = Scrapers::ASR.new('09-06-2022', today[:next_verification_token], File.open('cookies.txt')).investment_status
    #
    #   => { date: '09-06-2022', next_verification_token: 'xxx', table_lines: [...] }
    #
    # table_lines is a list of lists, representing each line in the html table (except headers)
    # each number is a float represented as a string
    # the list finishes with both "Totaal Beleggingen Module Pensioen" and "Te beleggen kapitaal"
    # in slightly different formats.
    #
    #   table_lines = [ ["name", "shares", "shareprice", "total", "percentage_of_total" ], ... ]
    #
    #   table_lines = [ ["ASR Duurzaam Wereldwijd Aandelen Fonds Hedged", "77.50", "23.22", "1799.69", "0.4451"] ]
    #
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
          content = content.sub('.', '')
          content = content.sub(',', '.')
          if content.match(/%$/)
            content = (content.sub(/%$/, '').to_r / 100)
            content = sprintf('%.4f', content)
          end
          if content.match(/^€\xC2\xA0/)
            content = content.sub(/^€\xC2\xA0/, '')
          end
          line << content
        end
        result << line
      end
      result
    end
  end
end
