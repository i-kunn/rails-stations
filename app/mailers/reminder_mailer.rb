# app/mailers/reminder_mailer.rb
class ReminderMailer < ApplicationMailer
  def notify
    @reservation = params[:reservation]
    to_email = params[:email].presence || @reservation&.email
    return if to_email.blank? # 念のため二重防御

    mail(to: to_email, subject: '【リマインド】明日のご予約について')
  end
end
