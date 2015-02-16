class Uimp::InformationController < ApplicationController

  require 'json'


  def service_information
  	#@info = parse_json_file 'app/assets/uimp/service_information.json'
    render :file => '/app/assets/uimp/service_information.json'
  end

  def authentication_policy
  	render :file => '/app/assets/uimp/authentication_policy.json'
  end

  def required_user_information
  	render :file => '/app/assets/uimp/required_user_information.json'
  end


  def parse_json_file(file_path)
  	file = File.read file_path
  	JSON.parse file
  end
end
