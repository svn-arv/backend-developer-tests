class Pathfinder
  attr_accessor :to

  MANHATTAN_DISTANCE = 'manhattan_distance'.freeze
  DJIKSTRA = 'djikstra'.freeze

  def initialize(
    grid:,
    from:,
    to:,
    distance_strategy: MANHATTAN_DISTANCE,
    pathfinding_strategy: DJIKSTRA
  )
    @grid = grid
    @from = from
    @to = to
    @distance_strategy = distance_strategy
    @pathfinding_strategy = pathfinding_strategy
  end

  def find_distance
    return 0 if @from.nil? || @to.nil?

    # For adding another strategy later (eg. Euclidean) if needed
    raise 'Not implemented' if @distance_strategy != MANHATTAN_DISTANCE 

    calculate_manhattan_distance
  end

  def calculate_manhattan_distance
    row_distance = (@from[:row] - @to[:row]).abs
    col_distance = (@from[:col] - @to[:col]).abs
    row_distance + col_distance
  end

  def find_path
    return nil if @from.nil? || @to.nil?

    # For adding another strategy later (eg. A* for even larger grid) if needed
    raise 'Not implemented' if @pathfinding_strategy != DJIKSTRA 

    djikstra_pathfinder
  end

  def djikstra_pathfinder
    distances = {}
    previous_positions = {}

    nodes = @grid.edges.keys.dup
    distances[@from] = 0

    while nodes.any?
      current_pos = nodes.min_by { |node| distances[node] || Float::INFINITY }
      break if current_pos == @to

      # Delete as we're travelling through the node
      nodes.delete(current_pos)

      @grid.edges[current_pos].each do |neighbor, weight|
        alternative = (distances[neighbor] || 0) + weight
        next if alternative >= (distances[neighbor] || Float::INFINITY)

        distances[neighbor] = alternative
        previous_positions[neighbor] = current_pos
      end
    end

    path = []
    current_pos = @to
    while current_pos
      path.unshift(current_pos)
      current_pos = previous_positions[current_pos]
    end

    path
  end
end