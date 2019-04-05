module Eleyo
  module API
    class Config
      def self.server_uri
        if Eleyo::API.standardmode?
          "https://config.reg.eleyo.com"
        elsif Eleyo::API.testmode?
          "https://config.reg.eleyo.green"
        elsif Eleyo::API.devmode?
          host = "#{`scutil --get LocalHostName`.downcase.strip}.local"
          "http://config.reg.eleyo.#{host}"
        end
      end

      attr_accessor :auth

      def initialize(options = {})
        self.auth = options[:auth]

        raise API::InitializerError.new(:auth, "can't be blank") if self.auth.nil?
        raise API::InitializerError.new(:auth, "must be of class type Eleyo::API::Auth") if !self.auth.is_a?(Eleyo::API::Auth)
      end

      def get(subdomain_or_sn)
        subdomain_or_sn = URI.escape(subdomain_or_sn.to_s)

        request = HTTPI::Request.new
        request.url = "#{self.class.server_uri}/v1/customers/#{subdomain_or_sn}"
        request.headers = self.generate_headers

        response = HTTPI.get(request)

        if !response.error?
          JSON.parse(response.body)
        else
          raise(API::Error.new(response.code, response.body))
        end
      end

      def get_by(key, value)
        key = URI.escape(key.to_s)
        value = URI.escape(value.to_s)

        request = HTTPI::Request.new
        request.url = "#{self.class.server_uri}/v1/customers/by/#{key}/#{value}"
        request.headers = self.generate_headers

        response = HTTPI.get(request)

        if !response.error?
          JSON.parse(response.body)
        else
          raise(API::Error.new(response.code, response.body))
        end
      end

      def list(params = {})
        request = HTTPI::Request.new
        request.url = "#{self.class.server_uri}/api/v1/customers.json"
        request.query = URI.encode_www_form(params)
        request.headers = self.generate_headers

        response = HTTPI.get(request)

        if !response.error?
          JSON.parse(response.body)
        else
          raise(API::Error.new(response.code, response.body))
        end
      end

      protected

      def generate_headers
        {'User-Agent' => USER_AGENT, 'Client-Secret' => self.auth.client_secret, 'Client-Id' => self.auth.client_id}
      end

    end
  end
end
