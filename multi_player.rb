require './your_player.rb'
require './pathfinder.rb'

class MultiPlayer < YourPlayer
  @@players = []
  @@assigned_areas = {}

  def initialize(game:, name:, player_count:)
    super(game: game, name: name)
    @@players << self
    if @@players.length == player_count
      divide_grid(player_count)
    end
  end

  def next_point(time:)
    if @current_position.nil?
      @current_position = find_start_in_area
    elsif @path.empty?
      target = find_nearest_unvisited_node_in_area
      if target
        pathfinder = Pathfinder.new(from: @current_position, to: target, grid: grid)
        @path = pathfinder.find_path
        @path.shift # Remove current position
      elsif !all_areas_completed?
        target = find_nearest_unvisited_node
        if target
          pathfinder = Pathfinder.new(from: @current_position, to: target, grid: grid)
          @path = pathfinder.find_path
          @path.shift
        end
      end
    end

    if @path.any?
      next_position = @path.shift
      @current_position = next_position if grid.is_valid_move?(from: @current_position, to: next_position)
    end

    @current_position
  end

  private

  def divide_grid(player_count)
    width = grid.max_col + 1
    height = grid.max_row + 1
    area_width = width / Math.sqrt(player_count).ceil
    area_height = height / Math.sqrt(player_count).ceil

    @@players.each_with_index do |player, index|
      start_row = (index / Math.sqrt(player_count).ceil) * area_height
      start_col = (index % Math.sqrt(player_count).ceil) * area_width
      end_row = [start_row + area_height, height].min
      end_col = [start_col + area_width, width].min

      @@assigned_areas[player] = {
        start_row: start_row,
        start_col: start_col,
        end_row: end_row,
        end_col: end_col
      }
    end
  end

  def find_start_in_area
    area = @@assigned_areas[self]
    (area[:start_row]...area[:end_row]).each do |row|
      (area[:start_col]...area[:end_col]).each do |col|
        point = { row: row, col: col }
        return point if grid.edges.key?(point)
      end
    end
  end

  def find_nearest_unvisited_node_in_area
    area = @@assigned_areas[self]
    unvisited_nodes = grid.edges.keys.reject { |grid_edge| grid.visited[grid_edge] }
                               .select { |point| point_in_area?(point: point, area: area) }
    return nil if unvisited_nodes.empty?
    pathfinder = Pathfinder.new(from: @current_position, to: nil, grid: grid)
    unvisited_nodes.min_by do |unvisited_node|
      pathfinder.to = unvisited_node
      pathfinder.find_distance
    end
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

  def point_in_area?(point:, area:)
    point[:row].between?(area[:start_row], area[:end_row] - 1) &&
    point[:col].between?(area[:start_col], area[:end_col] - 1)
  end

  def all_areas_completed?
    @@players.all? do |player|
      area = @@assigned_areas[player]
      (area[:start_row]...area[:end_row]).all? do |row|
        (area[:start_col]...area[:end_col]).all? do |col|
          point = { row: row, col: col }
          !grid.edges.key?(point) || grid.visited[point]
        end
      end
    end
  end

  def grid
    @grid ||= game.grid
  end
end