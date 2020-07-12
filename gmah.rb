require 'dotenv/load'
require 'telegram/bot'
require 'mechanize'

token = ENV['TOKEN']

def initialize_agent
  @agent = Mechanize.new
end

def search(*city)
  initialize_agent
  url = city.length != 0 ? ENV['URL'].dup.gsub!('city', city.first.downcase) : ENV['TOP_URL']
  @doc = @agent.get url
  fetch_response
end

def fetch_response
  results = []
  for i in 0..19 do
    result = {}
    price = @doc.search('.first-price')[i].text
    next if price.include? 'USD'
    expenses = @doc.search('.expenses')[i].text
    total_price = expenses != nil ? expenses.gsub!('.', '').gsub!('+ $ ', '').to_i + price.gsub!('.', '').gsub!('$ ', '').to_i : price.gsub!('.', '').gsub!('$ ', '').to_i
    address = @doc.search('.posting-location')[i].text.split(', ')[0].strip.capitalize
    size = @doc.search('.main-features')[i].text.split(' ')[0]
    url = ENV['BASE_URL'] + @doc.search('.posting-title a')[i].attr('href')
    result = {price: total_price, address: address, size: size, url: url}
    results.push(result)
  end
  results.sort_by { |i| i[:price] }
end

def send_message(bot, message, post, i)
  text = "#{i + 1})\nPrecio: $#{post[:price]} \nDirección: #{post[:address]} \nTamaño: #{post[:size]} m² \nURL: #{post[:url]}"
  bot.api.send_message(parse_mode: 'Markdown', chat_id: message.chat.id, text: text)
end

Telegram::Bot::Client.run(token) do |bot|
  bot.listen do |message|
    case message.text
    when '/top'
      bot.api.send_message(chat_id: message.chat.id, text: 'Buscando los 20 mejores departamentos en Recoleta, Palermo y Belgrano :)')
      response = search
    else
      response = search(message.text)
    end
    response.each_with_index do |post, i|
      send_message(bot, message, post, i)
    end
  end
end
