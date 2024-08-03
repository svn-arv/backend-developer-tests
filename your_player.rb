require './base_player.rb'
require './pathfinder.rb'

class YourPlayer < BasePlayer

  def initialize(game:,name:)
    super
    @current_position = nil
    @path = []
  end

  def next_point(time:)
    if @current_position.nil?
      @current_position = find_starting_point
    elsif @path.empty?
      target = find_nearest_unvisited_node
      if target
        pathfinder = Pathfinder.new(from: @current_position, to: target, grid: grid)
        @path = pathfinder.find_path
        @path.shift # Remove current position
      end
    end

    if @path.any?
      next_position = @path.shift
      puts next_position
      @current_position = next_position if grid.is_valid_move?(from: @current_position, to: next_position)
    end

    @current_position
  end

  private

  def find_starting_point
    # Find Best starting point by Sum of value of the Min Edge
    grid.edges.keys.min_by { |edge_point| grid.edges[edge_point].values.sum }
  end

  def find_nearest_unvisited_node
    unvisited_nodes = grid.edges.keys.reject { |edge_point| grid.visited[edge_point] }
    return nil if unvisited_nodes.empty?
    pathfinder = Pathfinder.new(from: @current_position, to: nil, grid: grid)
    unvisited_nodes.min_by do |unvisited_node| 
      pathfinder.to = unvisited_node
      pathfinder.find_distance
    end
  end

  def grid
    @grid ||= game.grid # Memoize the Grid
  end
end
