# frozen_string_literal: true

def reload!
  load File.dirname(__FILE__) + '/scrapers/bnd.rb'
  load File.dirname(__FILE__) + '/scrapers/boursorama.rb'
  load File.dirname(__FILE__) + '/scrapers/coingecko.rb'
  load File.dirname(__FILE__) + '/scrapers/ecb.rb'
  load File.dirname(__FILE__) + '/scrapers/eres.rb'
  load File.dirname(__FILE__) + '/scrapers/zonebourse.rb'
end
reload!
