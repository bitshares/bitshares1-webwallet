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
delegate_node.exec 'wallet_create', 'default', '123456789'
delegate_node.exec 'wallet_unlock', '9999999', '123456789'
puts

File.open('test_genesis.json.keypairs') do |f|
  counter = 0
  f.each_line do |l|
    pub_key, priv_key = l.split(' ')
    delegate_node.exec 'wallet_import_private_key', priv_key, "delegate#{counter}"
    counter += 1
  end
end

sleep 1.0

for i in 0..100
  delegate_node.exec 'wallet_delegate_set_block_production', "delegate#{i}", true
end

STDIN.getc
puts "quiting.."
delegate_node.exec 'quit'
sleep 1.0

puts "finished"
