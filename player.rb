require 'rest-client'
require 'json'

$team = '16'
$host = 'https://6f3726fb.ngrok.io'
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
  board.reduce({}) { |scores, coord|
    key = "#{coord['x']},#{coord['y']}"
    score = (scores[key] || 0)
    if coord['is_food']
      score = score + 1
    end
    scores.update({key => score})
  }
end

def calculate_closest_resource player_board
  # TODO Need to calculate which resource to go to based on need of player.
  player_location = { 'x' => player_board['player']['x'], 'y' => player_board['player']['y'] }
 
  resource_distances = player_board['board'].map { |location| 
    {
      'x' => location['x'],
      'y' => location['y'], 
      'resource' => location['is_food'] ? "🌴" : "💧",
      'distance' => (player_location['x'] + player_location['y'] - (location['x'] + location['y'])).abs
    } unless location['is_player']
  }
  resource_distances.min_by { |entry| entry['distance'] }
end

def calculate_direction_to_move player_location, other_location
  if player_location['x'] > other_location['x']
    'WEST'
  elsif player_location['x'] < other_location['x']
    'EAST'
  elsif player_location['y'] > other_location['y']
    'NORTH'
  elsif player_location['y'] < other_location['y']
    'SOUTH'
  else
    $directions.sample
  end
end

def get_location thing
  { 'x' => thing['x'], 'y' => thing['y'] }
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

puts calculate_closest_resource player_board

while player_board['player']['active'] do
  location_to_move_toward = calculate_closest_resource player_board

  if location_to_move_toward 
    puts "Moving to #{location_to_move_toward}"
    direction = calculate_direction_to_move (get_location player_board['player']), location_to_move_toward
  else 
    direction = $directions.sample
    puts "Moving randomly"
  end
  puts "\t-> #{direction}"
  player_board.update move direction

  puts "#{name} is now at (#{player_board['player']['x']}, #{player_board['player']['y']})"
  puts "\n\n#{name}'s 🌡: #{player_board['player']}"
  sleep 2
end

puts "#{name} has died 💀"
