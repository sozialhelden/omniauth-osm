require 'omniauth-oauth'

module OmniAuth
  module Strategies
    class Osm < OmniAuth::Strategies::OAuth
      option :name, "osm"

      option :client_options, {
        :site               => 'http://www.openstreetmap.org',
        :request_token_path => '/oauth/request_token',
        :access_token_path  => '/oauth/access_token',
        :authorize_path     => '/oauth/authorize'
      }

      uid{ raw_info['user']['id'] }

      info do
      {
        'name'       => raw_info['user']['display_name'],
        'languages'  => raw_info['user']['languages'].map(&:lang),
        'home'       => raw_info['user']['home'],
        'image_url'  => raw_info['user']['img']['href']
      }
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
