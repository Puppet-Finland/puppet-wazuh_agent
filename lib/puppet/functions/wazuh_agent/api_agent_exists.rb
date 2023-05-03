# frozen_string_literal: true

require 'net/http'
require 'json'
# @summary
#   A custom function to check the existense of an agent
#
# @author Kibahop <petri.lammi@puppeteers.net>
#
# @see https://documentation.wazuh.com/current/user-manual/api/reference.html#section/Authentication
Puppet::Functions.create_function(:'wazuh_agent::api_agent_exists') do
  # @param api_host API host
  # @param api_host_port API host port
  # @param api_username API username
  # @param api_password API password
  # @param api_agent_name API agent name
  # @return [Boolean] Returns a boolean
  dispatch :api_agent_exists? do
    param 'String', :api_host
    param 'Integer', :api_host_port
    param 'String', :api_username
    param 'String', :api_password
    param 'String', :api_agent_name
    return_type 'Boolean'
  end

  TOKEN_FILE = '/tmp/wazuh-token.json'
  TOKEN_EXPIRATION_DURATION = 900 # seconds
  TOKEN_EXPIRATION_BUFFER = 60 # seconds

  def handle_error(message)
    raise StandardError, "wazuh_agent::api_agent_exists: #{message}"
  end

  def load_token_from_file
    return unless File.exist?(TOKEN_FILE)

    begin
      token_data = JSON.parse(File.read(TOKEN_FILE))
      token_data
    rescue JSON::ParserError => e
      handle_error("failed to load token from file: #{e.message}")
    end
  end

  def save_token_to_file(token_data)
    File.write(TOKEN_FILE, token_data.to_json)
  rescue StandardError => e
    handle_error("failed to save token to file: #{e.message}")
  end

  def token_valid?(token_data)
    expiration_time = Time.parse(token_data['expiration'])
    expiration_time > Time.now + TOKEN_EXPIRATION_BUFFER
  end

  def retrieve_token(api_host, api_host_port, api_username, api_password)
    # check if token exists and is still valid
    token_data = load_token_from_file
    if token_data && token_valid?(token_data)
      return token_data['token']
    end

    # token needs to be retrieved
    uri = URI("https://#{api_host}:#{api_host_port}/security/user/authenticate")
    begin
      res = Net::HTTP.start(
        uri.host,
        uri.port,
        use_ssl: true,
        verify_mode: OpenSSL::SSL::VERIFY_NONE,
      ) do |http|
        req = Net::HTTP::Get.new(uri.path.to_s)
        req.basic_auth(api_username, api_password)
        http.request(req)
      end
    rescue Net::HTTPServerException => e
      handle_error("failed to retrieve agent token: #{e.message}")
    rescue StandardError => e
      handle_error("failed to retrieve agent token: #{e.message}")
    end

    if res.code == '200'
      begin
        data = JSON.parse(res.body)
        token = data['data']['token']
        expiration = Time.now + TOKEN_EXPIRATION_DURATION
        token_data = { 'token' => token, 'expiration' => expiration }
        save_token_to_file(token_data)
        token
      rescue StandardError => e
        handle_error("failed to extract agent token: #{e.message}")
      end
    else
      handle_error('error communicating with the server')
    end
  end

  def agent_exists?(api_host, api_host_port, token, api_agent_name)
    uri = URI("https://#{api_host}:#{api_host_port}/agents")
    query_params = { 'name' => api_agent_name }
    uri.query = URI.encode_www_form(query_params)
    headers = { 'Content-Type' => 'application/json', 'Authorization' => "Bearer #{token}" }

    begin
      res = Net::HTTP.start(
        uri.host,
        uri.port,
        use_ssl: true,
        verify_mode: OpenSSL::SSL::VERIFY_NONE,
      ) do |http|
        req = Net::HTTP::Get.new(uri.request_uri, headers)
        http.request(req)
      end
    rescue StandardError => e
      handle_error("error connecting to Wazuh API: #{e.message}")
    end

    return unless res.code == '200'
    begin
      data = JSON.parse(res.body)
    rescue JSON::ParserError => e
      handle_error("error parsing response body: #{e.message}")
    end

    case data['data']['total_affected_items']
    when 0
      false
    when 1
      true
    else
      handle_error('more than one affected_items in the server response')
    end
  end

  def api_agent_exists?(api_host, api_host_port, api_username, api_password, api_agent_name)
    token = retrieve_token(api_host, api_host_port, api_username, api_password)
    agent_exists?(api_host, api_host_port, token, api_agent_name)
  end
end
