$:.unshift File.expand_path('..', __FILE__)
$:.unshift File.expand_path('../../lib', __FILE__)
require 'simplecov'
require 'omniauth-osm'
require 'rspec'
require 'webmock/rspec'

require 'coveralls'
Coveralls.wear!