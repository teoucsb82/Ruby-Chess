require 'colorize'
require './piece'

class Board
  attr_accessor :pieces, :turn

  def initialize
    @pieces = []
    seed_board
    @turn = :white
  end

  # Make this to_s - make it not print anything
  def display_board
    (0..7).each do |row|
      print "#{8 - row} "
      (0..7).each  do |col|
        if (row.even? && col.even?) || (row.odd? && col.odd?)
          if find_piece([col, 7 - row]).nil?
            print "   ".colorize( :background => :green)
          else
            color = find_piece([col, 7 - row]).color
            icon_code = find_piece([col, 7 - row]).icon_code
            icon_code = icon_code.encode('utf-8')
            print " #{icon_code} ".colorize( color ).colorize(:background => :green)
          end
        else
          if find_piece([col, 7 - row]).nil?
            print "   ".colorize( :background => :blue)
          else
            color = find_piece([col, 7 - row]).color
            icon_code = find_piece([col, 7 - row]).icon_code
            icon_code = icon_code.encode('utf-8')
            print " #{icon_code} ".colorize( color).colorize(:background => :blue)
          end
        end
      end
      puts " "
    end
    puts "   a  b  c  d  e  f  g  h  "
  end

  def seed_board
    [[0, :white],[7, :black]].each do |y, color|
      self.pieces << Rook.new(color, [0, y], self)
      self.pieces << Knight.new(color, [1, y], self)
      self.pieces << Bishop.new(color, [2,y], self)
      self.pieces << Queen.new(color, [3,y], self)
      self.pieces << King.new(color, [4,y], self)
      self.pieces << Bishop.new(color, [5,y], self)
      self.pieces << Knight.new(color, [6,y], self)
      self.pieces << Rook.new(color, [7,y], self)
    end

    8.times { |col| self.pieces << Pawn.new(:white, [col, 1], self) }
    8.times { |col| self.pieces << Pawn.new(:black, [col, 6], self) }
  end

  def has_piece?(square)
    self.pieces.any? do |piece|
      piece.position == square
    end
  end

  def in_check?(color)
    king_square = find_king_position(color)
    attacking_pieces = find_eligible_attackers(color)

    attacking_pieces.any? do |piece|
      piece.legal_moves(piece.position).include?(king_square)
    end
  end

  def checkmate?(color)
    return false unless in_check?(color)

    #Ryan code
    # remaining_possible_moves(color).all? do |move|
    #   duped_board = self.dup
    #   piece = find_piece(move)
    #   move!(piece, move)
    #   duped_board.in_check?(color)
    # end

    duped_board = self.dup

    # pieces_for(color)
    remaining_defenders = duped_board.pieces.select {|duped_piece| duped_piece.color == color }

    remaining_defenders.each do |defender|
      defenders_moves = defender.legal_moves(defender.position)
      defenders_moves.each do |possible_move|
        defender_original_pos = defender.position
        defender.position = possible_move
        return false if defender.class == King && !move_into_check?(possible_move, color) && !duped_board.in_check?(color)
        defender.position = defender_original_pos
      end
    end

    true
  end

  def remaining_possible_moves(color)
    moves = []
    # each
    moves
  end

  def move_into_check?(pos, color)
    attacking_squares = []
    attacking_pieces = find_eligible_attackers(color)
    king_square = pos

    duped_board = self.dup
    piece_to_delete = duped_board.pieces.find{ |piece| piece.position == pos }
    duped_board.pieces.delete(piece_to_delete) unless piece_to_delete.nil?

    remaining_defenders = duped_board.pieces.select { |duped_piece| duped_piece.color != color }

    illegal_move = false
    remaining_defenders.each do |defender|
      piece_moves = defender.legal_moves(defender.position)
      illegal_move = true if piece_moves.include?(pos)
    end

    illegal_move
  end

  def exposed_to_check?(piece, end_square)
    duped_board = self.dup

    test_piece = duped_board.pieces.find {|duped_piece| duped_piece.position == piece.position}
    test_piece.position = end_square

    duped_board.in_check?(test_piece.color)
  end

  def find_king_position(color)
    self.pieces.find { |piece| piece.class == King && piece.color == color }.position
  end

  # def pieces_for(color)
  def find_eligible_attackers(color)
    self.pieces.select do |piece|
      piece.color != color
    end
  end

  def find_piece(square)
    self.pieces.find do |piece|
      piece.position == square
    end
  end

  def dup
    duped = super
    duped.pieces = self.pieces.map(&:dup)
    duped.pieces.each do |piece|
      piece.board = duped
    end
    duped
  end

  def move(piece, end_square)
    moved_into_check = move_into_check?(end_square, piece.color) if piece.class == King

    if piece.legal_moves(piece.position).include?(end_square) && !moved_into_check && piece.color == self.turn && !exposed_to_check?(piece, end_square)
      # don't puts
      puts "You moved your #{piece.class} to #{convert_to_algebraic(end_square)}"
      capture_piece(self.find_piece(end_square))
      piece.position = end_square
      change_turn(self.turn)
      true
    else
      # raise errors
      puts "You may only move a piece of your own color" unless piece.color == self.turn
      puts "You cannot make a move that would leave you in check" if exposed_to_check?(piece, end_square)
      puts "You cannot move into check" if moved_into_check
      puts "Illegal Move"
      # raise InvalidMoveError -- fix this later
      false
    end

  end

  def move!(piece, end_square)
    capture_piece(self.find_piece(end_square))
    piece.position = end_square
  end

  def change_turn(color)
    @turn = color == :white ? :black : :white
  end

  def capture_piece(piece)
    # don't puts
    puts "You captured the #{piece.to_s} on #{convert_to_algebraic(piece.position)}" unless piece.nil?
    self.pieces.delete(piece)
  end

  def convert_to_algebraic(position)
    first_value = (position[0] + 97).chr
    second_value = (position[1] + 1).to_s
    return first_value + second_value
  end

  def convert_to_numeric(string)
    arr = []
    arr[0] = string[0].ord - 97
    arr[1] = Integer(string[1]) - 1
    arr
  end

end
