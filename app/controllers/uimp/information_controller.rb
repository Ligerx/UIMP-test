class Uimp::InformationController < ApplicationController
  layout false
  
  def service_information
    render :file => '/app/assets/uimp/service_information.json'
  end

  def authentication_policy
  	render :file => '/app/assets/uimp/authentication_policy.json'
  end

  def required_user_information
  	render :file => '/app/assets/uimp/required_user_information.json'
  end
end
