class FireworksMailer < ActionMailer::Base
  default from: ENV["mailer_reply_address"]
  default to: "malekerwin.karim@petronas.com.my"

  def test_mail
      mail(subject: "Test Mail")
  end

  def address_feature_users licserver, feature_name
      mail(subject: "ATTN: #{feature_name} Users")
  end
end
