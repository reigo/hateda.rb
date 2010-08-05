#! /usr/bin/ruby
require 'rubygems'
require 'atomutil'
require 'pit'
require 'rexml/document'

config = Pit.get('hatena.ne.jp', :require => {
	'username' => 'username in hatena',
	'password' => 'password in hatena'
})

module REXML
  class Text < Child
    def clone
      #return Text.new(self)
      return Text.new(self.to_s, false, nil, true)
    end
  end
end

module Atompub
  class HatenaClient < Client
    def publish_entry(uri)
      @hatena_publish = true
      update_resource(uri, ' ', Atom::MediaType::ENTRY.to_s)
    ensure
      @hatena_publish = false
    end

    private
    def set_common_info(req)
      req['X-Hatena-Publish'] = 1 if @hatena_publish
      super(req)
    end
  end
end

auth = Atompub::Auth::Wsse.new :username => config['username'], :password => config['password']
client = Atompub::HatenaClient.new :auth => auth
service = client.get_service 'http://d.hatena.ne.jp/%s/atom' % config['username']
collection_uri = service.workspace.collections[1].href

title,content = File.read(ARGV[0]).split(/\n/,2)

entry = Atom::Entry.new(
  :title => title,
  :updated => Time.now,
  :content => content
)

puts client.create_entry collection_uri, entry

