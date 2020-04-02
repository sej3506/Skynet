require 'rest-client'
require 'json'

$team = '39'
$host = 'http://retreat-game.herokuapp.com'
$directions = ['NORTH', 'SOUTH', 'WEST', 'EAST']

def move direction
  JSON.parse(RestClient.post("#{$host}/api/moves", {'direction' => direction}, {'TEAM' => $team}).body)
end

def show
  JSON.parse(RestClient.get("#{$host}/api/player", {'TEAM' => $team}).body)
end

def create name, water, food, stamina, strength
  JSON.parse(RestClient.post("#{$host}/api/players",
    { 'player[name]' => name, 'player[water_stat]' => water,
      'player[food_stat]' => food, 'player[stamina_stat]' => stamina,
      'player[strength_stat]' => strength}, {'TEAM' => $team}).body)
end

def calculate_resource_score board
  board.reduce { |scores, coord|
    key = "#{coord['x']},#{coord['y']}"
    score = (scores[key] || 0)
    if coord['is_food']
      score = score + 1
    end
    scores.update({key => score})
  }
end

name = "Bob"
water = 5
food = 5
stamina = 5
strength = 5
player_board = create name, water, food, stamina, strength

if player_board['player']['active']
  puts "#{name} lives! 🎉"
else
  puts "#{name} is not alive 😢"
  exit
end

while player_board['player']['active'] do
  player_board.update(move $directions.sample)

  puts "#{name} is now at (#{player_board['player']['x']}, #{player_board['player']['y']})"
  puts calculate_resource_score player_board['board']
  sleep 2
end

puts "#{name} has died 💀"
