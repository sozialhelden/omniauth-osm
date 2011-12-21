require 'spec_helper'

describe OmniAuth::Strategies::Osm do
  before :each do
    @request = double('Request')
    @request.stub(:params) { {} }
  end

  subject do
    OmniAuth::Strategies::Osm.new(nil, @options || {}).tap do |strategy|
      strategy.stub(:request) { @request }
    end
  end

  describe '#client_options' do
    it 'has correct Osm site' do
      subject.options.client_options.site.should eq('http://www.openstreetmap.org')
    end

    it 'has correct authorize url' do
      subject.options.client_options.authorize_url.should eq('http://www.openstreetmap.org/oauth/authorize')
    end

    it 'has correct request token url' do
      subject.options.client_options.request_token_url.should eq('http://www.openstreetmap.org/oauth/request_token')
    end

    it 'has correct access token url' do
      subject.options.client_options.access_token_url.should eq('http://www.openstreetmap.org/oauth/access_token')
    end
  end

  describe '#id' do
    it 'returns the id from raw_info' do
      subject.stub(:raw_info) {{ 'user' => { 'id' => '123' } } }
      subject.uid.should eq('123')
    end
  end

  describe '#info' do
    before :each do
      @raw_info ||= { 'user' => { 'display_name' => 'Fred', 'languages' => {'lang' => ["de-DE", "de"]}, 'home' => {'lat' => '52.0', 'lon' => '13.4', 'zoom' => '3' }, 'img' => {'href' => 'http://somewhere.com/image.jpg'} } }
      subject.stub(:raw_info) { @raw_info }
    end

    context 'when data is present in raw info' do
      it 'returns the name' do
        subject.info['name'].should eq('Fred')
      end

      it 'returns the languages' do
        subject.info['languages'].should eq(['de-DE', 'de'])
      end

      it 'returns no languages if missing' do
        @raw_info['user'].delete('languages')
        subject.info['languages'].should eq([])
      end

      it 'returns the lat' do
        subject.info['lat'].should eq(52.0)
      end

      it 'returns no lat if missing' do
        @raw_info['user'].delete('home')
        subject.info['lat'].should eq(nil)
      end

      it 'returns the lon' do
        subject.info['lon'].should eq(13.4)
      end

      it 'returns no lon if missing' do
        @raw_info['user'].delete('home')
        subject.info['lon'].should eq(nil)
      end

      it 'returns the image' do
        subject.info['image_url'].should eq('http://somewhere.com/image.jpg')
      end

      it 'returns no image of missing' do
        @raw_info['user'].delete('img')
        subject.info['image_url'].should eq(nil)

      end
    end
  end
end