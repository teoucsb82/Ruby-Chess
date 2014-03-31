require 'colorize'
require './board'

class Piece

  VERTICALS =  [[0, 1], [0, -1]]
  HORIZONTALS = [[1, 0], [-1, 0]]
  DIAGONALS =   [[1, 1],
                 [-1, -1],
                 [1, -1],
                 [-1, 1]]


  attr_accessor :position, :board
  attr_reader :color, :icon_code

  def initialize(color, position, board)
    @color, @position, @board = color, position, board
    @icon_code
  end

  def to_s
    self.color.to_s + " " + self.class.to_s
  end

  def legal_moves(position)
    possible_squares = []

    self.move_dirs.each do |direction|
      possible_squares += move_in_direction(direction)
    end

    possible_squares
  end

  def move_in_direction(direction)
    moves = []

    self.iterations.times do |idx|
      square = [(self.position[0] + ((idx + 1) * direction[0])), (self.position[1] + ((idx + 1) * direction[1]))]

      unless @board.find_piece(square).nil?
        if (@board.find_piece(square).color != self.color)
          moves << square
          return moves
        end
      end

      return moves if @board.has_piece?(square)
      return moves unless (square[0].between?(0, 7) && square[1].between?(0, 7))
      moves << square
    end

    moves
  end

  def iterations
    self.class::NUMBER_OF_ITERATIONS
  end

  # def to_s
    # PIECE_SYMBOLS[self.class.to_s.to_sym].color(color)
  # end
end

class SlidingPiece < Piece
  NUMBER_OF_ITERATIONS = 7
end

class SteppingPiece < Piece
  NUMBER_OF_ITERATIONS = 1
end

class Rook < SlidingPiece
  def initialize(color, position, board)
    super
    @icon_code = self.color == :black ? "\u265C" : "\u2656"
  end

  def move_dirs
    VERTICALS + HORIZONTALS
  end
end

class Bishop < SlidingPiece

  def initialize(color, position, board)
    super
    @icon_code = self.color == :black ? "\u265D" : "\u2657"
  end

  def move_dirs
    DIAGONALS
  end

end

class Queen < SlidingPiece

  def initialize(color, position, board)
    super
    @icon_code = self.color == :black ? "\u265B" : "\u2655"
  end

  def move_dirs
    HORIZONTALS + VERTICALS + DIAGONALS
  end

end

class Knight < SteppingPiece

  def initialize(color, position, board)
    super
    @icon_code = self.color == :black ? "\u265E" : "\u2658"
  end

  def move_dirs
    return [[1, 2],
            [-1, 2],
            [1, -2],
            [-1, -2],
            [2, 1],
            [-2, 1],
            [2, -1],
            [-2, -1]]
  end

end

class King < SteppingPiece

  def initialize(color, position, board)
    super
    @icon_code = self.color == :black ? "\u265A" : "\u2654"
  end

  def move_dirs
    HORIZONTALS + VERTICALS + DIAGONALS
  end

end

class Pawn < Piece
  attr_reader :starting_position

  def initialize(color, position, board)
    super
    @starting_position = position
    @icon_code = self.color == :black ? "\u265F" : "\u2659"
  end

  def move_dirs
    verticals = self.color == :white ? [[0, 1]] : [[0, -1]]
    diagonals = self.color == :white ? [[1, 1],[-1, 1]] : [[-1, -1], [1, -1]]
    return (verticals + diagonals)
  end

  def legal_moves(position)
    possible_squares = []

    self.move_dirs.each do |direction|
      possible_squares += move_in_direction(direction)
    end

    temp_square = self.color == :white ? [self.starting_position[0],self.starting_position[1] + 1] : [self.starting_position[0],self.starting_position[1] - 1]

    if self.position == self.starting_position && !@board.has_piece?(temp_square)
      temp_direction = self.color == :white ? [0, 2] : [0, -2]
      possible_squares += move_in_direction(temp_direction)
    end

    possible_squares
  end

  def on_starting_position?
    if self.color == :white
      self.position[1] == 6
    else
      self.position[1] == 1
    end
  end

  def move_in_direction(direction)
    moves = []

    square = [(self.position[0] + direction[0]), (self.position[1] + direction[1])]

    if DIAGONALS.include?(direction)
      return moves unless @board.has_piece?(square) && ((@board.find_piece(square)).color != self.color)
      return moves unless (square[0].between?(0,7) && square[1].between?(0,7))
    else
      return moves if @board.has_piece?(square)
      return moves unless (square[0].between?(0,7) && square[1].between?(0,7))
    end

    moves << square

    moves
  end
end

