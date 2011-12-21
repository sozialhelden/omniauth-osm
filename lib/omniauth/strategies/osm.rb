require 'omniauth-oauth'

module OmniAuth
  module Strategies
    class Osm < OmniAuth::Strategies::OAuth
      option :name, "osm"

      option :client_options, {
        :site               => 'http://www.openstreetmap.org',
        :request_token_url => 'http://www.openstreetmap.org/oauth/request_token',
        :access_token_url  => 'http://www.openstreetmap.org/oauth/access_token',
        :authorize_url     => 'http://www.openstreetmap.org/oauth/authorize'
      }

      uid{ raw_info['user']['id'] }

      info do
      {
        'name'       => raw_info['user']['display_name'],
        'languages'  => languages,
        'lat'        => lat,
        'lon'        => lon,
        'image_url'  => image_url
      }
      end

      def lat
        raw_info['user']['home']['lat'].to_f rescue nil
      end

      def lon
        raw_info['user']['home']['lon'].to_f rescue nil
      end

      def languages
        raw_info['user']['languages']['lang'] rescue []
      end

      def image_url
        raw_info['user']['img']['href'] rescue nil
      end

      extra do
        { 'raw_info' => raw_info }
      end

      def raw_info
        @raw_info ||= Hash.from_xml(access_token.get('/api/0.6/user/details.json').body)['osm']
        rescue ::Errno::ETIMEDOUT
        raise ::Timeout::Error
      end
    end
  end
end
