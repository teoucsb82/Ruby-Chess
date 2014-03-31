# encoding: utf-8

require 'colorize'
require './board'
require './piece'
require './player'
#require 'chess'

class Chess
  def initialize
    @player1 = Player.new("Teo", :white)
    @player2 = Player.new("Will", :black)
    @board = Board.new
  end

  # Move turn logic into Chess class

  def play
    until game_over?

      @board.display_board

      from, to = get_user_input

      piece = @board.find_piece(from)
      @board.move(piece, to)
    end

    end_game(@board.turn)
  end

  def get_user_input
    start_position = [-1, -1]
    end_position = [-1, -1]

    until start_position[0].between?(0,7) && start_position[1].between?(0,7) &&
          end_position[0].between?(0,7) && end_position[1].between?(0,7)

      puts "#{@board.turn.to_s.upcase} player's turn. Please enter your move (ex: a1, b1)"
      user_move_input = gets.chomp
      first_coordinate = user_move_input.split(",")[0].strip
      second_coordinate = user_move_input.split(",")[1].strip

      start_position = @board.convert_to_numeric(first_coordinate)
      end_position = @board.convert_to_numeric(second_coordinate)
    end

    [start_position, end_position]
  end

  def end_game(color)
    @board.display_board
    puts "----------------------------------------------"
    puts "#{color.capitalize} King is in CHECKMATE!!"
    puts color == :white ? "Black wins!" : "White wins!"
    puts "----------------------------------------------"
  end

  def game_over?
    @board.checkmate?(:white) || @board.checkmate?(:black)
  end
end


if __FILE__ == $PROGRAM_NAME
  game = Chess.new
  game.play
end