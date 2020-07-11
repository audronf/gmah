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
  url = ENV['URL'].dup.gsub! 'city', city.downcase
  doc = @agent.get url
  results = []
  for i in 0..4 do
    result = {}
    price = doc.search('.first-price')[i].text
    next if price.include? 'USD'
    expenses = doc.search('.expenses')[i].text
    total_price = expenses != nil ? expenses.gsub!('.', '').gsub!('+ $ ', '').to_i + price.gsub!('.', '').gsub!('$ ', '').to_i : price.gsub!('.', '').gsub!('$ ', '').to_i
    address = doc.search('.posting-location')[i].text.split(', ')[0].strip.capitalize
    features = doc.search('.main-features')[i].text.split(' ')[0]
    url = ENV['BASE_URL'] + doc.search('.posting-title a').attr('href').value
    result = {price: total_price, address: address, features: features, url: url}
    results.push(result)
  end
  results.sort_by { |i| i[:price] }
end

Telegram::Bot::Client.run(token) do |bot|
  bot.listen do |message|
    case message.text
    when '/top10'
      bot.api.send_message(chat_id: message.chat.id, text: top10)
    else
      response = search(message.text)
      response.each_with_index do |post, i|
        text = "#{i + 1})\nPrecio: $#{post[:price]} \nDirección: #{post[:address]} \nTamaño: #{post[:features]} m² \nURL: #{post[:url]}"
        bot.api.send_message(parse_mode: 'Markdown', chat_id: message.chat.id, text: text)
      end
    end
  end
end

def top10
  response = 'Test'
  response
end
