class Uimp::InformationController < ApplicationController
  require 'json'
  layout false
  
  STATIC_FILE_PATH = File.join(Rails.root, "app", "assets", "uimp")

  def service_information
  	#@info = parse_json_file 'app/assets/uimp/service_information.json'
    render :file => '/app/assets/uimp/service_information.json'
    
    # send_file File.join(STATIC_FILE_PATH, "service_information.json")
  end

  def authentication_policy
  	render :file => '/app/assets/uimp/authentication_policy.json'
  end

  def required_user_information
  	render :file => '/app/assets/uimp/required_user_information.json'
  end
end
