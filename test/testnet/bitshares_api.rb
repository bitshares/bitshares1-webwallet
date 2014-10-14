require 'net/http'
require 'uri'
require 'json'

module BitShares
  class API

    @@rpc_instance = nil

    def self.init(username, password)
      @@rpc_instance = BitShares::API::Rpc.new(username, password)

    end

    def self.rpc
      @@rpc_instance
    end

    class Wallet
      def self.method_missing(name, *params)
        BitShares::API::rpc.request("wallet_" + name.to_s, params)
      end
    end

    class Network
      def self.method_missing(name, *params)
        BitShares::API::rpc.request("network_" + name.to_s, params)
      end
    end

    class Blockchain
      def self.method_missing(name, *params)
        BitShares::API::rpc.request("blockchain_" + name.to_s, params)
      end
    end

    class Rpc

      class Error < RuntimeError; end

      def initialize(username, password)
        @uri = URI('http://localhost:5680/rpc')
        @req = Net::HTTP::Post.new(@uri)
        @req.content_type = 'application/json'
        @req.basic_auth username, password
      end

      def request(method, params)
        result = nil
        Net::HTTP.start(@uri.hostname, @uri.port) do |http|
          @req.body = { method: method, params: params || [], id: 0 }.to_json
          http.request(@req).body
          response = http.request(@req)
          result = JSON.parse(response.body)
          raise Error, result['error'] if result['error']
        end
        return result['result']
      end

    end

  end

end

 
if $0 == __FILE__
  BitShares::API.init('user', 'pass')
  accounts = BitShares::API::Wallet.list_my_accounts()
  first_account = accounts[0]['name']
  puts BitShares::API::Wallet.account_transaction_history(first_account)
  puts BitShares::API::Wallet.market_order_list("USD", "BTSX")
  puts BitShares::API::Blockchain.list_assets("USD", 1)
end
