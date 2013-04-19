require 'active_support/core_ext'
require 'nokogiri'
require 'httparty'

class FlightDeals
  class << self
    def qatar_special_response
      options = {
          :timeout => 5,
          :headers => {
              'Content-Type' => 'application/x-www-form-urlencoded',
              'X-Requested-With' => 'XMLHttpRequest',
              'Referer' => 'http://www.qatarairways.com/au/en/special-offers.page?from=MEL&to=WAW&source_page=latest_offer',
              'User-Agent' => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_7_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/28.0.1479.0 Safari/537.36',


          },
          :body => 'country_id=en_au&departureFrom=Melbourne++(MEL)&departureTo=&FromDate=&ToDate=&TypesList=&sourcepage=filter'

      }

      @qatar_special_response ||= HTTParty.post('http://www.qatarairways.com/english_australia/include/FlightSearchResult.page', options)
    end

    def qatar_special
      html = Nokogiri::HTML.parse(qatar_special_response)
      specials = html.css('div table tr').inject([]) do |mem, row|
        cells = row.css('td')
        unless cells.empty?
          cells = cells.map(&:text)
          h = {
              #       :from => cells[0],
              :destination => cells[1],
              :class => cells[2],
              :book_by => cells[3],
              :depart => cells[4],
              :price => cells[5],
              #        :terms_conditions => cells[6],
              :airways => 'QATAR'
          }
          mem << h
        end
        mem
      end
      specials
    end

    def emirates_special_response
      options = {
          :timeout => 5,

          :headers => {
              'Content-Type' => 'application/x-www-form-urlencoded',
              'Referer' => 'http://www.emirates.com/au/english/destinations_offers/special_offers/special_fares/special_fares.aspx',
              'User-Agent' => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_7_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/28.0.1479.0 Safari/537.36',
          },
          :body => '__VIEWSTATE=&__VIEWSTATEENCRYPTED=&txtHeaderSearch=Search&siteSelectorID=0&city=192403&currentPanelOpen=&__SEOVIEWSTATE=dMb7Sg%2B1%2FcCif03Yi%2FzeEcFHKDaGQCccGPCfAXtzr1td1ffIIb7RA6S7NaQUqpsPSEIxJGZsHXhVJ7zdDkH4%2BtFq%2BHBQPhaWqv%2BnO8w6HE1d2Rl1'

      }

      @emirates_special_response ||= HTTParty.post('http://www.emirates.com/au/english/destinations_offers/special_offers/special_fares/special_fares.aspx', options)
    end

    def emirates_special

      html = Nokogiri::HTML.parse(emirates_special_response)
      prev_dest = nil
      specials = html.css('#column2 .borderContainer table.displayTable tr').inject([]) do |mem, row|
        cells = row.css('td.detail')
        unless cells.empty?
          c = cells[0]
          c.css('.hiddenContainer').remove
          dest = c.text
          dest = prev_dest if dest.blank?
          prev_dest = dest
          h = {
              :destination => dest,
              :price => cells[1].text,
              :class => cells[2].text,
              :book_by => cells[3].text,
              :depart => cells[4].text,
              :airways => 'EMIRATES'
          }
          mem << h
        end
        mem
      end
    end

    def qantas_specials_response
      options = {
          :timeout => 5,

          :headers => {
              'Referer' => 'http://www.qantas.com.au/travel/airlines/international-flight-specials/from-melbourne/premium-economy/global/en',
              'User-Agent' => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_7_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/28.0.1479.0 Safari/537.36',
          },
      }
      @qantas_specials_response ||= HTTParty.get('http://www.qantas.com.au/travel/airlines/international-flight-specials/from-melbourne/economy/global/en', options)
    end

    def qantas_specials
      html = Nokogiri::HTML.parse(qantas_specials_response)
      html.css('.flightSpecialsResults .resultWrap .resultDetails .detail').inject([]) do |mem,row|
        dst = row.css('h3')
        dst.css('small').remove
        dst.css('span').remove
        h = {
            :destination => dst.text.strip,
            :price => row.css('.dynPrice').text,
            :airways => 'QANTAS'

        }
        mem << h
      end
    end

    def __all_specials
      qatar_special + emirates_special + qantas_specials
    end


    def all_specials
      10.times do
        begin
          return __all_specials
        rescue Timeout::Error => e
          puts 'Timeout... retrying...'
        end
      end
      raise Timeout::Error.new
    end

    def specials_to(*dst)
      all_specials.select { |s| dst.any?{|d| s[:destination].include?(d)} }
    end
  end
end
