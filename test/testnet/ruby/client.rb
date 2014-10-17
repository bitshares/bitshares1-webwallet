require 'open3'
require_relative './bitshares_api.rb'

class BitSharesNode

  attr_reader :rpc_instance

  class Error < RuntimeError; end

  def initialize(client_binary, options)
    @client_binary, @options = client_binary, options

  end
  
  def start
    command = @client_binary
    command << " --data-dir #{@options[:data_dir]}"
    command << " --genesis-config #{@options[:genesis]}"
    command << " --min-delegate-connection-count=0"
    command << " --server"
    command << " --rpcuser=user"
    command << " --rpcpassword=pass"
    command << " --httpport=#{@options[:http_port]}"
    command << " --upnp=false"
    command << " --disable-default-peers"
    if @options[:delegate]
      command << " --p2p-port=10000"
    else
      command << " --connect-to=127.0.0.1:10000"
    end

    puts "starting client: #{command}"
    
    stdin, out, wait_thr = Open3.popen2e(command)
    while true
      if select([out], nil, nil, 0.2) and out.eof?
        puts "process exited and doesn't have output queued."
        break
      else
        line = out.gets
        puts line
        break if line.include? "Starting HTTP JSON RPC server on port #{@options[:http_port]}"
      end
    end
    
    sleep 1.0
    
    @rpc_instance = BitShares::API::Rpc.new(@options[:http_port], 'user', 'pass', ignore_errors: false)

  end

  def exec(method, params = nil)
    raise  Error, "rpc instance is not defined, make sure the node is started" unless @rpc_instance
    @rpc_instance.request(method, params)
  end

end