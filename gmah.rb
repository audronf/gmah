require 'dotenv/load'
require 'nokogiri'
require 'open-uri'
require 'telegram/bot'
require 'openssl'
require 'httparty'
require 'byebug'
require 'mechanize'

token = ENV['TOKEN']

def search(city)
  @agent = Mechanize.new
  url = ENV['URL'].dup.gsub! 'city', city
  doc = @agent.get url
  doc.search('posting-card').each do |card|
    post = card.search('go-to-posting').click
    Mechanize.back
  end
  'Test' 
end

def prepare_search_response(doc)
  results = doc.css('posting-card', 'div')
  response = {}
  results.each do |result|
    result.click
    price = i
  end
end

Telegram::Bot::Client.run(token) do |bot|
  bot.listen do |message|
    case message.text
    when '/top10'
      bot.api.send_message(chat_id: message.chat.id, text: top10)
    else
      response = search(message.text)
      bot.api.send_message(chat_id: message.chat.id, text: response)
    end
  end
end

def top10
  response = 'Test'
  response
end
