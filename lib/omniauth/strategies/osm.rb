require 'omniauth-oauth'
require 'rexml/document'

module OmniAuth
  module Strategies
    class Osm < OmniAuth::Strategies::OAuth
      option :name, "osm"

      option :client_options, :site => 'http://www.openstreetmap.org'
      option :fetch_permissions, false

      uid { raw_info['id'] }

      info do
        raw_info
      end

      def raw_info
        @raw_info ||= parse_info(access_token.get('/api/0.6/user/details').body)
        @raw_info['permissions'] ||= parse_permissions(access_token.get('/api/0.6/permissions').body) if options[:fetch_permissions]
        @raw_info
        rescue ::Errno::ETIMEDOUT
        raise ::Timeout::Error
      end

      # EXAMPLE XML
      #
      # <?xml version="1.0" encoding="UTF-8"?>
      # <osm generator="OpenStreetMap server" version="0.6">
      #   <user display_name="freundchen" account_created="2011-01-07T14:35:24Z" id="392638">
      #     <img href='http://foo.bar.net/logo.gif' />
      #     <description>Test description</description>
      #     <contributor-terms pd="false" agreed="true"/>
      #     <home lon="13.411681556178" zoom="3" lat="52.524360979625"/>
      #     <languages>
      #       <lang>de-DE</lang>
      #       <lang>de</lang>
      #     </languages>
      #   </user>
      # </osm>

      private
      def parse_info(xml_data)
        # extract event information
        doc = REXML::Document.new(xml_data)
        user = doc.elements['//user']
        home = doc.elements['//home']
        languages = doc.get_elements('//lang')
        image = doc.elements['//img']
        description = doc.elements['//description']
        basic_attributes = { }
        basic_attributes['id']           = user.attribute('id').value if user
        basic_attributes['display_name'] = user.attribute('display_name').value if user
        basic_attributes['languages']    = languages.map(&:text) if languages
        basic_attributes['image_url']    = image.attribute('href').value if image
        basic_attributes['lat']          = home.attribute('lat').value.to_f if home
        basic_attributes['lon']          = home.attribute('lon').value.to_f if home
        basic_attributes['description']  = description.text if description
        basic_attributes
      end

      def parse_permissions(xml_data)
        # extract event information
        doc = REXML::Document.new(xml_data)
        doc.get_elements('//permission').map { |p| p.attribute('name').value }
      end
    end
  end
end
