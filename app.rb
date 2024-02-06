# frozen_string_literal: true

require 'sinatra'
require 'json'

require_relative 'files.rb'

get '/' do
  'OK!'
end

SCRAPERS = {
  boursorama: Scrapers::Boursorama,
  bnd: Scrapers::BND,
  coingecko: Scrapers::Coingecko,
  coingecko_inverted: Scrapers::CoingeckoInverted,
  ecb: Scrapers::ECB,
  eres: Scrapers::Eres,
  zonebourse: Scrapers::Zonebourse
}.freeze

get '/:scraper/:id' do
  scraper = SCRAPERS[params[:scraper].to_sym]
  halt 404 if scraper.nil?

  id = params[:id]
  halt 404 unless id.match?(/^[a-zA-Z0-9\-\._]+$/)

  headers 'Content-Type' => 'application/json'
  JSON.pretty_generate(scraper.new(id).quotation_history)
end

post '/asr' do
  cookiesFile = params[:cookies] ? params[:cookies][:tempfile] : nil

  headers 'Content-Type' => 'application/json'
  JSON.pretty_generate(Scrapers::ASR.new(params[:date], params[:verification_token], cookiesFile).investment_status)
end
