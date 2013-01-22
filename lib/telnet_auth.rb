# https://github.com/darrenhinderer/telnet-server/blob/master/telnet_auth.rb

require 'active_record'
require_relative 'models'

class TelnetAuth

  def initialize(connection)
    @connection = connection

    @state = :init
    send_username_request
  end

  def send_username_request
    @state = :username_request
    @connection.send_prompt("Username: ", :red)
  end

  def send_password_request
    @state = :password_request
    @connection.send_prompt("Password: ", :red)
  end

  def send_signup_username_request
    @state = :signup_username_request
    @connection.send_prompt("New Username: ", :red)
  end

  def send_signup_password_request
    @state = :signup_password_request
    @connection.send_prompt("New Password: ", :red)
  end

  def send_signup_result
    player = Models::Player.new
    player.username = @new_username
    player.password = @new_password
    if player.save
      @state = :logged_in
      @username = @new_username
      @connection.send_line("Signup success.")
      @connection.start_shell
    else
      @state = :init
      @connection.send_line("Signup failed.")
      send_username_request
    end 
  end

  def authenticate
    player = Models::Player.find_by_username(@username)     
    if !player.nil? && player.password == @password
      @connection.send_line("")
      @state = :logged_in
      @connection.start_shell
    else
      @state = :init
      @connection.send_line("Login failed.\r\n")
      send_username_request
    end
  end

  def process_response(data)
    case @state
    when :init
      send_username_request
    when :username_request
      if data == "new"
        send_signup_username_request
      else
        @username = data
        send_password_request
      end
    when :password_request
      @password = data
      authenticate
    when :signup_username_request
      @new_username = data
      send_signup_password_request
    when :signup_password_request
      @new_password = data
      send_signup_result
    else
      abort @state + data
    end
  end

  def state
    @state
  end

  def username
    @username
  end
end
