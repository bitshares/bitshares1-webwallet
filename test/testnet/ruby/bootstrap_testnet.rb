#!/usr/bin/env ruby

require 'fileutils'
require 'yaml'
require 'open3'
require_relative './client.rb'

BITSHARES_TOOLKIT_BUILD_PATH = '/Users/vz/bitshares/osx_build'

Dir.mkdir 'tmp' unless Dir.exist? 'tmp'
tempdir = 'tmp' # + '/' + 10.times.map{ Random.rand(10).to_s }.join()

puts "testnet dir #{tempdir}"

FileUtils.rm_r tempdir + '/delegate', :force => true
FileUtils.rm_r tempdir + '/client_a', :force => true
FileUtils.rm_r tempdir + '/client_b', :force => true
Dir.mkdir tempdir unless Dir.exist? tempdir
Dir.mkdir tempdir + '/delegate'
Dir.mkdir tempdir + '/client_a'
Dir.mkdir tempdir + '/client_b'

client_binary = BITSHARES_TOOLKIT_BUILD_PATH + '/programs/client/bitshares_client'

start_delegate_command = client_binary
start_delegate_command << " --data-dir #{tempdir}/delegate"
start_delegate_command << " --genesis-config test_genesis.json"
start_delegate_command << " --min-delegate-connection-count=0"
start_delegate_command << " --server"
start_delegate_command << " --rpcuser=user"
start_delegate_command << " --rpcpassword=pass"
start_delegate_command << " --httpport=5690"
start_delegate_command << " --upnp=false"
start_delegate_command << " --p2p-port=10000"
start_delegate_command << " --disable-default-peers"
#start_delegate_command << " --connect-to=127.0.0.1:10000"
#start_delegate_command << " --daemon"

#${INVICTUS_ROOT}/programs/client/bitshares_client --data-dir "$tmp_datadir" --genesis-config init_genesis.json --server --min-delegate-connection-count=0

puts "command: #{start_delegate_command}"

stdin, out, wait_thr = Open3.popen2e(start_delegate_command)
while true
  if select([out], nil, nil, 0.2) and out.eof?
    puts "process exited and doesn't have output queued."
    break
  else
    line = out.gets
    puts "out: " + line
    break if line.include? "Starting HTTP JSON RPC server on port 5690"
  end
end

sleep 1.0

delegate_rpc_instance = BitShares::API::Rpc.new(5690, 'user', 'pass', ignore_errors: false)


puts '====== creating default vallet ======'
delegate_rpc_instance.request('wallet_create', ['default', '123456789'])
delegate_rpc_instance.request('wallet_unlock', ['9999999', '123456789'])
puts


#puts API::Misc.get_info().to_yaml

# puts '====== import key ======'
# API::Wallet.import_private_key('5JF2Yo1sgL3JA1ZmH8Wc11MdNxEtTE2nCiZuqTudam7yiyVX5x1', 'valzav', true, true)
# puts

File.open('test_genesis.json.keypairs') do |f|
  counter = 0
  f.each_line do |l|
    pub_key, priv_key = l.split(' ')
    delegate_rpc_instance.request('wallet_import_private_key', [priv_key, "delegate#{counter}"])
    counter += 1
    #break if counter == 11
  end
end

sleep 1.0

for i in 0..100
  delegate_rpc_instance.request('wallet_delegate_set_block_production', ["delegate#{i}", true])
end

STDIN.getc
puts "quiting.."
delegate_rpc_instance.request('quit')
sleep 1.0