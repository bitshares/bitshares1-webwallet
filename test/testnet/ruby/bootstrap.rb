#!/usr/bin/env ruby

require 'fileutils'
require 'yaml'
require 'open3'
require_relative './client.rb'

def recreate_dir(dir); FileUtils.rm_rf(dir); Dir.mkdir(dir) end

TEMPDIR = 'tmp'
def td(path); "#{TEMPDIR}/#{path}"; end

Dir.mkdir TEMPDIR unless Dir.exist? TEMPDIR
recreate_dir td('delegate')
recreate_dir td('alice')
recreate_dir td('bob')

@client_binary = ENV['BTS_BUILD'] + '/programs/client/bitshares_client'

@bts_node = BitSharesNode.new @client_binary, data_dir: td('delegate'), genesis: "test_genesis.json", http_port: 5690, delegate: true
@bts_node.start

def create_client_node(dir, port, create=true)
  clientnode = BitSharesNode.new @client_binary, data_dir: td(dir), genesis: "test_genesis.json", http_port: port
  clientnode.start
  if create
    clientnode.exec 'wallet_create', 'default', '123456789'
    clientnode.exec 'wallet_unlock', '9999999', '123456789'
  end
  return clientnode
end

def full_bootstrap
  puts '========== full bootstrap ==========='
  FileUtils.rm_rf td('delegate_wallet_backup.json')
  FileUtils.rm_rf td('alice_wallet_backup.json')
  FileUtils.rm_rf td('bob_wallet_backup.json')
  @bts_node.exec 'wallet_create', 'default', '123456789'
  @bts_node.exec 'wallet_unlock', '9999999', '123456789'
  puts

  File.open('test_genesis.json.keypairs') do |f|
    counter = 0
    f.each_line do |l|
      pub_key, priv_key = l.split(' ')
      @bts_node.exec 'wallet_import_private_key', priv_key, "delegate#{counter}"
      counter += 1
      #break if counter > 10
    end
  end

  sleep 1.0

  for i in 0..10
    @bts_node.exec 'wallet_delegate_set_block_production', "delegate#{i}", true
  end

  balancekeys = []
  File.open('test_genesis.json.balancekeys') do |f|
    f.each_line do |l|
      balancekeys << l.split(' ')[1]
    end
  end

  @bts_node.exec 'wallet_import_private_key', balancekeys[0], "account0", true, true
  @bts_node.exec 'wallet_import_private_key', balancekeys[1], "account1", true, true

  for i in 0..100
    @bts_node.exec 'wallet_delegate_set_block_production', "delegate#{i}", true
  end

  @bts_node.wait_new_block

  for i in 0..100
    @bts_node.exec 'wallet_transfer', 1000000, 'XTS', "account#{i%2}",  "delegate#{i}"
  end

  @bts_node.wait_new_block
  #STDIN.getc

  res = @bts_node.exec 'wallet_account_transaction_history'
  res.each do |trx|
    next if trx['block_num'].to_i == 0
    @bts_node.exec 'wallet_scan_transaction', trx['trx_id']
  end

  for i in 0..100
    @bts_node.exec 'wallet_publish_price_feed', "delegate#{i}", 0.01, 'USD'
  end
  
  @bts_node.exec 'wallet_backup_create', td('delegate_wallet_backup.json')

  @client_node_a = create_client_node('alice', 5691)
  @client_node_a.exec 'wallet_import_private_key', balancekeys[2], "account2", true, true
  # @client_node_a.exec 'wallet_account_create', 'tester-a'
  # @client_node_a.exec 'wallet_account_register', 'tester-a', 'account2'
  # @client_node_a.exec 'wallet_transfer', 100000000, 'XTS', 'account2',  'tester-a'
  @client_node_a.exec 'wallet_backup_create', td('alice_wallet_backup.json')

  @client_node_b = create_client_node('bob', 5692)
  @client_node_b.exec 'wallet_import_private_key', balancekeys[3], "account3", true, true
  # @client_node_b.exec 'wallet_account_create', 'tester-b'
  # @client_node_b.exec 'wallet_account_register', 'tester-b', 'account3'
  # @client_node_b.exec 'wallet_transfer', 100000000, 'XTS', 'account3',  'tester-b'
  @client_node_b.exec 'wallet_backup_create', td('bob_wallet_backup.json')
end

def quick_bootstrap
  puts '========== quick bootstrap ==========='
  @bts_node.exec 'wallet_backup_restore', td('delegate_wallet_backup.json'), 'default', '123456789'
  @client_node_a = create_client_node('alice', 5691, false)
  @client_node_a.exec 'wallet_backup_restore', td('alice_wallet_backup.json'), 'default', '123456789'
  @client_node_b = create_client_node('bob', 5692, false)
  @client_node_b.exec 'wallet_backup_restore', td('bob_wallet_backup.json'), 'default', '123456789'
end

if File.exist? td ('delegate_wallet_backup.json') and ARGV[0] != 'full'
  quick_bootstrap
else
  full_bootstrap
end

STDIN.getc
puts "quiting.."
@bts_node.exec 'quit'
@client_node_a.exec 'quit' if @client_node_a
@client_node_b.exec 'quit' if @client_node_b
sleep 1.0

puts "finished"
