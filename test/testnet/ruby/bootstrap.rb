#!/usr/bin/env ruby

require 'fileutils'
require 'yaml'
require 'open3'
require_relative './client.rb'

def recreate_dir(dir); FileUtils.rm_rf(dir); Dir.mkdir(dir) end

BITSHARES_TOOLKIT_BUILD_PATH = '/Users/vz/bitshares/osx_build'

tempdir = 'tmp'

puts "testnet dir #{tempdir}"

Dir.mkdir tempdir unless Dir.exist? tempdir
recreate_dir tempdir + '/delegate'
recreate_dir tempdir + '/client_a'
recreate_dir tempdir + '/client_b'

client_binary = BITSHARES_TOOLKIT_BUILD_PATH + '/programs/client/bitshares_client'

delegate_node = BitSharesNode.new client_binary, data_dir: "#{tempdir}/delegate", genesis: "test_genesis.json", http_port: 5690, delegate: true
delegate_node.start

puts '====== creating default vallet ======'
delegate_node.exec 'wallet_create', ['default', '123456789']
delegate_node.exec 'wallet_unlock', ['9999999', '123456789']
puts

File.open('test_genesis.json.keypairs') do |f|
  counter = 0
  f.each_line do |l|
    pub_key, priv_key = l.split(' ')
    delegate_node.exec 'wallet_import_private_key', [priv_key, "delegate#{counter}"]
    counter += 1
    #break if counter == 28
  end
end

sleep 1.0
#STDIN.getc

for i in 0..100
  delegate_node.exec 'wallet_delegate_set_block_production', ["delegate#{i}", true]
end

STDIN.getc
puts "quiting.."
delegate_node.exec 'quit'
sleep 1.0

puts "finished"


# /Users/vz/.rbenv/versions/2.1.3/lib/ruby/2.1.0/net/protocol.rb:153:in `read_nonblock': end of file reached (EOFError)
# 	from /Users/vz/.rbenv/versions/2.1.3/lib/ruby/2.1.0/net/protocol.rb:153:in `rbuf_fill'
# 	from /Users/vz/.rbenv/versions/2.1.3/lib/ruby/2.1.0/net/protocol.rb:134:in `readuntil'
# 	from /Users/vz/.rbenv/versions/2.1.3/lib/ruby/2.1.0/net/protocol.rb:144:in `readline'
# 	from /Users/vz/.rbenv/versions/2.1.3/lib/ruby/2.1.0/net/http/response.rb:39:in `read_status_line'
# 	from /Users/vz/.rbenv/versions/2.1.3/lib/ruby/2.1.0/net/http/response.rb:28:in `read_new'
# 	from /Users/vz/.rbenv/versions/2.1.3/lib/ruby/2.1.0/net/http.rb:1408:in `block in transport_request'
# 	from /Users/vz/.rbenv/versions/2.1.3/lib/ruby/2.1.0/net/http.rb:1405:in `catch'
# 	from /Users/vz/.rbenv/versions/2.1.3/lib/ruby/2.1.0/net/http.rb:1405:in `transport_request'
# 	from /Users/vz/.rbenv/versions/2.1.3/lib/ruby/2.1.0/net/http.rb:1378:in `request'
# 	from /Users/vz/bitshares/web_wallet/test/testnet/ruby/bitshares_api.rb:61:in `block in request'
# 	from /Users/vz/.rbenv/versions/2.1.3/lib/ruby/2.1.0/net/http.rb:853:in `start'
# 	from /Users/vz/.rbenv/versions/2.1.3/lib/ruby/2.1.0/net/http.rb:583:in `start'
# 	from /Users/vz/bitshares/web_wallet/test/testnet/ruby/bitshares_api.rb:59:in `request'
# 	from /Users/vz/bitshares/web_wallet/test/testnet/ruby/client.rb:54:in `exec'
# 	from ./bootstrap.rb:44:in `block in <main>'
# 	from ./bootstrap.rb:43:in `each'
# 	from ./bootstrap.rb:43:in `<main>'
