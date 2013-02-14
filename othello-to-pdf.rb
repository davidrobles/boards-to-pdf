#!/usr/bin/ruby

class OthelloPDF

  LETTERS = %w(A B C D E F G H)
  
  # options
  BLACK   = 'B'
  WHITE   = 'W'
  PATTERN = 'P'
  MOVE    = 'X'
  
  X_OFFSET = 17.0
  CELLS_SIDE = 8
  CELL_SIZE = 20
  OFFSET = 10
  PRINT_LETTERS = true

  def initialize(board, filename='board', path=Dir.pwd)
    @board = board
    @path = path
    @filename = filename
    @file = File.open("#@path/#@filename.ps", 'w')
    generate
  end

  def ps(str)
    @file.puts str
  end

  def generate
    draw
    save
    convert
  end

  def draw
    draw_background
    draw_grid
    draw_symbols
    draw_letters
  end

  def draw_background
    # bg = [153, 204, 153]
    bg = [153, 204, 102]
    # bg = [102, 153, 51]
    col = bg.map { |c| c / 255.0 }.join(' ')
    
    tmp = CELLS_SIDE * CELL_SIZE
    ps ''
    ps '%%%%%%%%%%%%%%'
    ps '% BACKGROUND %'
    ps '%%%%%%%%%%%%%%'
    ps ''
    ps "newpath"
    ps "10 10 moveto"
    ps "0 #{tmp} rlineto"
    ps "#{tmp} 0 rlineto"
    ps "0 -#{tmp} rlineto"
    ps "-#{tmp} 0 rlineto"
    ps "closepath"
    ps "0.9 setgray"
    # ps "%s setrgbcolor" % col
    ps "fill"
  end

  def draw_grid
    ps ''
    ps '%%%%%%%%'
    ps '% GRID %'
    ps '%%%%%%%%'

    (CELLS_SIDE + 1).times do |step|
      # horizontal
      ps ""
      ps "\% horizontal line #{step}"
      ps ""
      ps "newpath"
      ps "%f %f moveto" % [OFFSET, step * CELL_SIZE + OFFSET]
      ps "%f %f lineto" % [CELLS_SIDE * CELL_SIZE + OFFSET, step * CELL_SIZE + OFFSET]
      ps "0 setgray"
      ps "stroke"
      # vertical
      ps ""
      ps "\% vertical line #{step}"
      ps ""
      ps "newpath"
      ps "%f %f moveto" % [step * CELL_SIZE + OFFSET, OFFSET]
      ps "%f %f lineto" % [step * CELL_SIZE + OFFSET, CELLS_SIDE * CELL_SIZE + OFFSET]
      ps "0 setgray"
      ps "stroke"
    end
  end

  def draw_symbols
    ps ''
    ps '%%%%%%%%%%'
    ps '% STONES %'
    ps '%%%%%%%%%%'

    @board.reverse.each_with_index do |row, ri|
      row.each_with_index do |col, ci|
        circle_args = [ci * CELL_SIZE + (CELL_SIZE / 2) + OFFSET, ri * CELL_SIZE + (CELL_SIZE / 2) + OFFSET, CELL_SIZE * 0.35]
        if col.upcase == BLACK
          draw_stone 0, circle_args
        elsif col.upcase == WHITE
          draw_stone 1, circle_args
        elsif col.upcase == PATTERN
          draw_pattern(ri, ci)
        elsif col.upcase == MOVE
          draw_move(ri, ci)
        end
      end
    end
  end

  def draw_letters
    LETTERS.each_with_index do |letter, i|
      ps '/Helvetica findfont'
      ps '10 scalefont'
      ps 'setfont'
      ps 'newpath'
      ps '%d %d moveto' % [i * CELL_SIZE + OFFSET + (CELLS_SIDE - 1), CELLS_SIDE * CELL_SIZE + OFFSET + 4]
      ps '(%s) show' % LETTERS[i]
    end

    CELLS_SIDE.times do |i|
      ps '/Helvetica findfont'
      ps '10 scalefont'
      ps 'setfont'
      ps 'newpath'
      ps '%d %d moveto' % [0, i * CELL_SIZE + OFFSET + (CELLS_SIDE - 1)]
      ps '(%s) show' % [(CELLS_SIDE - i).to_s]
    end
  end

  def draw_stone(colour, circle_args)
    ps "%d setgray" % [colour]
    ps "%d %d %d 0 360 arc fill" % circle_args 
    ps "0 setgray"
    ps "%d %d %d 0 360 arc stroke" % circle_args
  end

  def draw_move(row, col)
    # /
    ps "newpath"
    ps "%f %f moveto" % [col * CELL_SIZE + OFFSET + (CELL_SIZE * 0.35), row * CELL_SIZE + OFFSET + (CELL_SIZE * 0.35)]
    ps "%f %f rlineto" % [CELL_SIZE * 0.30, CELL_SIZE * 0.30]
    ps "0 setgray"
    ps "stroke"
    # \
    ps "newpath"
    ps "%f %f moveto" % [col * CELL_SIZE + CELL_SIZE + OFFSET - (CELL_SIZE * 0.35), row * CELL_SIZE + OFFSET + (CELL_SIZE * 0.35)]
    ps "%f %f rlineto" % [-CELL_SIZE * 0.30, CELL_SIZE * 0.30]
    ps "0 setgray"
    ps "stroke"
  end

  def draw_pattern(row, col)
    ps "newpath\n"
    ps "%f %f moveto" % [col * CELL_SIZE + (CELL_SIZE / 2) + OFFSET, row * CELL_SIZE  + OFFSET + (CELL_SIZE * 0.2)]
    ps "%f %f rlineto" % [(CELL_SIZE / 2) - (CELL_SIZE * 0.2), (CELL_SIZE / 2) - (CELL_SIZE * 0.2)]
    ps "%f %f rlineto" % [-(CELL_SIZE / 2) + (CELL_SIZE * 0.2), (CELL_SIZE / 2) - (CELL_SIZE * 0.2)]
    ps "%f %f rlineto" % [-(CELL_SIZE / 2) + (CELL_SIZE * 0.2), -(CELL_SIZE / 2) + (CELL_SIZE * 0.2)]
    ps "%f %f rlineto" % [CELL_SIZE / 2, -(CELL_SIZE / 2)]
    ps "0 setgray"
    ps "fill"
    # ps "newpath\n"
    # ps "%f %f moveto" % [col * CELL_SIZE + (CELL_SIZE / 2) + OFFSET, row * CELL_SIZE  + OFFSET + (CELL_SIZE * 0.2)]
    # ps "%f %f rlineto" % [(CELL_SIZE / 2) - (CELL_SIZE * 0.2), (CELL_SIZE / 2) - (CELL_SIZE * 0.2)]
    # ps "%f %f rlineto" % [-(CELL_SIZE / 2) + (CELL_SIZE * 0.2), (CELL_SIZE / 2) - (CELL_SIZE * 0.2)]
    # ps "%f %f rlineto" % [-(CELL_SIZE / 2) + (CELL_SIZE * 0.2), -(CELL_SIZE / 2) + (CELL_SIZE * 0.2)]
    # ps "%f %f rlineto" % [(CELL_SIZE / 2) - (CELL_SIZE * 0.2), -(CELL_SIZE / 2) + (CELL_SIZE * 0.2)]
    # ps "0 setgray"
    # ps "stroke"
  end

  def save
    ps "showpage"
    @file.close
  end

  def convert
    system "ps2pdf", "#@path/#@filename.ps", "#@path/#@filename-tmp.pdf"
    system "pdfcrop", "#@path/#@filename-tmp.pdf", "#@path/#@filename.pdf"
    system "rm", "#@path/#@filename.ps" 
    system "rm", "#@path/#@filename-tmp.pdf"
  end

end

filestr = IO.read('/Users/drobles/Desktop/hello.txt')
boards = filestr.split("\n\n")

# require 'pp'

boards.each_with_index do |board, i|
  puts 'hello'
  rows = board.split("\n")
  matrix = rows.map { |row| row.split('') }
  OthelloPDF.new(matrix, "board-#{i}")
end
