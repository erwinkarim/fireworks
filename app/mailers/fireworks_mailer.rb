class FireworksMailer < ActionMailer::Base
  default from: "Fireworks <#{ENV["mailer_reply_address"]}>"
  layout 'mailer'

  def test_mail email
      mail(to: email, subject: "Test Mail")
  end

  def address_feature_users licserver, feature_name, message, sender_email
      mailing_list = Feature.get_mailing_list licserver.id, feature_name
      @message = message
      mail(cc: sender_email, bcc: mailing_list, subject: "ATTN: #{feature_name} Users")
  end
end
