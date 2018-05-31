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
    it 'has correct default production site' do
      OmniAuth::Strategies::Osm.site.should eq('https://www.openstreetmap.org')
    end

    it 'should use the correct environment site override' do
      stub_const("ENV", {'OSM_AUTH_SITE' => 'http://api06.dev.openstreetmap.org'})
      # Can't test the subject directly here as the site was set on class load,
      # but could still override it via an options hash if you wanted to
      OmniAuth::Strategies::Osm.site.should eq('http://api06.dev.openstreetmap.org')
    end
  end

  describe '#uid' do
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

  describe 'failure' do

    it "parsed should be an empty hash" do
      @parsed = subject.send(:parse_info, 'You dont\'t have sufficient right to do that.')
      @parsed.should eq({"languages" => []})
    end

    it "initializes raw_info properly if no xml is returned" do
      response_body = "foo bar"
      access_token = double(:get => double(:body => response_body))
      subject.should_receive(:access_token).and_return(access_token)

      subject.raw_info.should eq({"languages" => []})
    end
  end
end