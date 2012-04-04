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
  end

  describe '#id' do
    it 'returns the id from raw_info' do
      subject.stub(:raw_info) { { 'id' => '123' } }
      subject.uid.should eq('123')
    end
  end

  FULL_XML = <<-EOX
<?xml version="1.0" encoding="UTF-8"?>
<osm generator="OpenStreetMap server" version="0.6">
  <user display_name="freundchen" account_created="2011-01-07T14:35:24Z" id="392638">
    <img href="http://somewhere.com/image.jpg" />
    <description>Test description</description>
    <contributor-terms pd="false" agreed="true"/>
    <home lon="13.411681556178" zoom="3" lat="52.524360979625"/>
    <languages>
      <lang>de-DE</lang>
      <lang>de</lang>
    </languages>
  </user>
</osm>
EOX

  MINI_XML = <<-EOX
<?xml version="1.0" encoding="UTF-8"?>
<osm generator="OpenStreetMap server" version="0.6">
  <user display_name="freundchen" account_created="2011-01-07T14:35:24Z" id="392638">
    <description/>
    <contributor-terms pd="false" agreed="true"/>
  </user>
</osm>
EOX

  describe '#info' do
    before :each do
      @parsed = subject.send(:parse_info, FULL_XML)
      @mini_parsed = subject.send(:parse_info, MINI_XML)
    end

    context 'when data is present in raw info' do
      it 'returns the name' do
        @parsed['display_name'].should eq('freundchen')
      end

      it 'returns the languages' do
        @parsed['languages'].should eq(['de-DE', 'de'])
      end

      it 'returns no languages if missing' do

        @mini_parsed['languages'].should eq([])
      end

      it 'returns the lat' do
        @parsed['lat'].should eq(52.524360979625)
      end

      it 'returns no lat if missing' do
        @mini_parsed['lat'].should eq(nil)
      end

      it 'returns the lon' do
        @parsed['lon'].should eq(13.411681556178)
      end

      it 'returns no lon if missing' do
        @mini_parsed['lon'].should eq(nil)
      end

      it 'returns the image' do
        @parsed['image_url'].should eq('http://somewhere.com/image.jpg')
      end

      it 'returns no image of missing' do
        @mini_parsed['image_url'].should eq(nil)
      end
    end
  end
end