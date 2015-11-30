#! /usr/local/bin/ruby

require "gosu"

class NilClass

  def [](thing)
    nil
  end

end

module TheGameOfLife

WIDTH = 800
HEIGHT = 600
BLOCKSIZE = 20

private

class Board

  def initialize(file_name)
    @grid = []
    @is_moving = false
    if file_name == ""
      (HEIGHT / BLOCKSIZE).times do |y|
        new_row = []
        (WIDTH / BLOCKSIZE).times do |x|
          new_row.push(rand(2) == 0)
        end
        @grid.push new_row
      end
    else
      file = File.read("examples/" + file_name)
      lines = file.split("\n")
      lines.each do |line|
        new_row = []
        line.split("").each do |item|
          if item == "."
            new_row.push true
          else
            new_row.push false
          end
        end
        if line.split("").length < (WIDTH / BLOCKSIZE)
          ((WIDTH / BLOCKSIZE) - line.split("").length).times do
            new_row.push false
          end
        end
        @grid.push new_row
      end
      if @grid.length < (HEIGHT / BLOCKSIZE)
        ((HEIGHT / BLOCKSIZE) - @grid.length).times do
          new_row = []
          (WIDTH / BLOCKSIZE).times do |x|
            new_row.push false
          end
          @grid.push new_row
        end
      end
    end
  end

  def draw
    Gosu.draw_rect(0, 0, WIDTH, HEIGHT, 0xff_000000)
    @grid.each_with_index do |row, y|
      row.each_with_index do |item, x|
        if item == true
          Gosu.draw_rect(x * BLOCKSIZE, y * BLOCKSIZE, BLOCKSIZE, BLOCKSIZE, 0xff_ffffff)
        end
      end
    end
  end

  def update
    if @is_moving
      new_grid = []
      (HEIGHT / BLOCKSIZE).times do |y|
        new_row = []
        (WIDTH / BLOCKSIZE).times do |x|
          new_row.push false
        end
        new_grid.push new_row
      end
      @grid.each_with_index do |row, y|
        row.each_with_index do |item, x|
          if item == true
            nebors = [@grid[y - 1][x - 1], @grid[y - 1][x], @grid[y - 1][x + 1], @grid[y][x - 1], @grid[y][x + 1], @grid[y + 1][x - 1], @grid[y + 1][x], @grid[y + 1][x + 1]]
            total_alive = 0
            total_dead = 0
            nebors.each do |item_thing|
              if item_thing == true
                total_alive += 1
              end
              if item_thing == false
                total_dead += 1
              end
            end
            if total_alive < 2 || total_alive > 3
              new_grid[y][x] = false
            else
              new_grid[y][x] = true
            end
          else
            nebors = [@grid[y - 1][x - 1], @grid[y - 1][x], @grid[y - 1][x + 1], @grid[y][x - 1], @grid[y][x + 1], @grid[y + 1][x - 1], @grid[y + 1][x], @grid[y + 1][x + 1]]
            total_alive = 0
            total_dead = 0
            nebors.each do |item_thing|
              if item_thing == true
                total_alive += 1
              end
              if item_thing == false
                total_dead += 1
              end
            end
            if total_alive == 3
              new_grid[y][x] = true
            end
          end
        end
      end
      @grid = new_grid
    end
  end

  def mouse_down(x, y)
    if @grid[(y / BLOCKSIZE).to_i][(x / BLOCKSIZE).to_i] == true
      @grid[(y / BLOCKSIZE).to_i][(x / BLOCKSIZE).to_i] = false
    else
      @grid[(y / BLOCKSIZE).to_i][(x / BLOCKSIZE).to_i] = true
    end
  end

  def start_or_stop
    if @is_moving == true
      @is_moving = false
    else
      @is_moving = true
    end
  end

  def clear
    @grid = []
    (HEIGHT / BLOCKSIZE).times do |y|
      new_row = []
      (WIDTH / BLOCKSIZE).times do |x|
        new_row.push false
      end
      @grid.push new_row
    end
  end

end

public

class Screen < Gosu::Window

  def initialize(file_name)
    super WIDTH, HEIGHT
    self.caption = "The Game of Life"
    @board = Board.new(file_name)
    @prev_time = Time.new
    @speed = 250
  end

  def draw
    @board.draw
  end

  def update
    if (Time.new - @prev_time) * 1000.0 > @speed
      @board.update
      @prev_time = Time.new
    end
    if Gosu::button_down? Gosu::KbEqual
      @speed -= 5
    end
    if Gosu::button_down? Gosu::KbMinus
      @speed += 5
    end
  end

  def button_down(id)
    if id == Gosu::MsLeft
      @board.mouse_down(mouse_x, mouse_y)
    elsif id == Gosu::KbReturn
      @board.start_or_stop
    elsif id == Gosu::KbC
      @board.clear
    end
  end

  def needs_cursor?
    true
  end

end

end

print "Enter file name to open (don't type anything, and it will randomly generate a board): "

# enter a file that is in the examples folder

# a file in the examples folder has a "." for alive and a " " for dead

TheGameOfLife::Screen.new(gets.chomp).show if __FILE__ == $0
