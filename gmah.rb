require 'dotenv/load'
require 'telegram/bot'

token = ENV['TOKEN']

Telegram::Bot::Client.run(token) do |bot|
  bot.listen do |message|
    case message.text
    when '/top10'
      bot.api.send_message(chat_id: message.chat.id, text: 'Test')
    else
      bot.api.send_message(chat_id: message.chat.id, text: message.text)
    end
  end
end
