class UserMailer < ActionMailer::Base
  default from: Proc.new { ["TaxonWorks <noreply@#{Settings.mail_domain}>"] }
  
  def welcome_email(user)
    @user = user
    mail(to: user.email, subject: 'Welcome to TaxonWorks')
  end
  
  def password_reset_email(user, token)
    @user = user
    @token = token
    mail(to: user.email, subject: 'Password reset request for TaxonWorks')
  end

  # Send a message that the server will be up/down or intermitant in the near future
  def maintenance_email(body, subject = 'TaxonWorks - Upcoming maintenance')
    @body = body
    mail(bcc: User.pluck(:email), subject: subject) 
  end

end
