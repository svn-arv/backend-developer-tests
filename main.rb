require './game.rb'
require './random_player.rb'
require './your_player.rb'
require './helper.rb'

srand(129)

grid_size = 100 # Changed as Required in README.md

MULTIPLAYER = 'multi_player'.freeze
SINGLEPLAYER = 'single_player'.freeze

your_strategy = -> {
  mode = SINGLEPLAYER
  if mode == MULTIPLAYER
    players = PLAYER_COUNT.times.map do |i|
      MultiPlayer.new(game: game, name: "Player #{i+1}", player_count: PLAYER_COUNT)
    end

    players.each { |player| game.add_player(player) }
  else
    game = Game.new(grid_size: grid_size)

    you = YourPlayer.new(game: game, name: 'Sevian Arivyartha')

    game.add_player(you)
  end

  game.start
}

random_strategy = -> {
  game = Game.new(grid_size: grid_size)

  random_player = RandomPlayer.new(game: game, name: 'Rando 1')
  random_player2 = RandomPlayer.new(game: game, name: 'Rando 2')

  game.add_player(random_player)
  game.add_player(random_player2)

  game.start
}

random_results = random_strategy.call
your_results = your_strategy.call

compare_hashes(your_results, random_results)
