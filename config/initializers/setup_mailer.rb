ActionMailer::Base.smtp_settings = {
  address: 'smtp.gmail.com',
  port: 587,
  user_name: 'uimp.test',
  password: 'uimp-test',
  authentication: 'plain',
  enable_starttls_auto: true
}