require 'dotenv/load'
require 'nokogiri'
require 'open-uri'
require 'telegram/bot'
require 'openssl'
require 'httparty'
require 'byebug'

token = ENV['TOKEN']

def search(city)
  url = ENV['URL'] #.gsub 'city', city
  doc = Nokogiri::HTML(HTTParty.get(url))
  results = doc.css('list-right-container', 'div')
end

Telegram::Bot::Client.run(token) do |bot|
  bot.listen do |message|
    case message.text
    when '/top10'
      bot.api.send_message(chat_id: message.chat.id, text: top10)
    else
      response = search(message.text).length
      bot.api.send_message(chat_id: message.chat.id, text: response)
    end
  end
end

def top10
  response = 'Test'
  response
end
