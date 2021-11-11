# sounds :
# Beetlemuse, JonnyRuss01, zivs, unadamlar, Mudkip2016 and Kastenfrosch from https://freesound.org/
# music opengamearts syncopika

require 'gosu'

class BoxesGame
  GAME_ROOT_PATH = File.expand_path(".", __dir__)

  SOUNDS = {
    pallet_ok: Gosu::Sample.new("#{BoxesGame::GAME_ROOT_PATH}/sfx/423930__mudkip2016__correct.wav"),
    box_ok: Gosu::Sample.new("#{BoxesGame::GAME_ROOT_PATH}/sfx/476178__unadamlar__correct-choice.wav"),
    box_nok: Gosu::Sample.new("#{BoxesGame::GAME_ROOT_PATH}/sfx/478191__jonnyruss01__beep-error-1.ogg"),
    box_missed: Gosu::Sample.new("#{BoxesGame::GAME_ROOT_PATH}/sfx/521973__kastenfrosch__error.ogg"),
    box_placed: Gosu::Sample.new("#{BoxesGame::GAME_ROOT_PATH}/sfx/433770__zivs__ammo-pickup-1.ogg"),
    alert: Gosu::Sample.new("#{BoxesGame::GAME_ROOT_PATH}/sfx/529628__beetlemuse__alert-2.wav")
  }

  def self.main_score
    @@main_score
  end

  def self.main_score=(score)
    @@main_score = score
  end

  BoxesGame.main_score = 0
  MISSED_SCORE = -50

  class Pallet
    FONT = Gosu::Font.new(14)
    COLORS = {
      green: Gosu::Color.new(255, 76, 255, 0),
      blue: Gosu::Color.new(255, 72, 0, 255),
      yellow: Gosu::Color.new(255, 255, 216, 0)
    }
    SCORES = {
      correct: 20,
      wrong: 5,
      slice: 200
    }

    def initialize(x, y, w, h)
      @x, @y, @w, @h = x, y, w, h
      @boxes = []
      @main_color = nil
      @correct, @wrong, @score = 0, 0, 0
    end

    def get_next_destination
      # will be slices of 2 x 5 boxes
      box_count = @boxes.size + 1

      offset_x = 0
      offset_y = 0

      case box_count
      when 1
        offset_x = 0
        offset_y = 0
      when 2
        offset_x = 0
        offset_y = 1
      when 3
        offset_x = 0
        offset_y = 2
      when 4
        offset_x = 0
        offset_y = 3
      when 5
        offset_x = 0
        offset_y = 4
      when 6
        offset_x = 1
        offset_y = 0
      when 7
        offset_x = 1
        offset_y = 1
      when 8
        offset_x = 1
        offset_y = 2
      when 9
        offset_x = 1
        offset_y = 3
      when 10
        offset_x = 1
        offset_y = 4
      end

      x = @x + 4 + offset_x * 48
      y = @y + 4 + offset_y * 33

      {x: x, y: y}
    end

    def add_box(box)
      destination = get_next_destination
      box.set_destination(destination[:x], destination[:y])
      @boxes.push(box)

      if @main_color.nil?
        @main_color = box.color
        @correct += 1
        @score += SCORES[:correct]
        SOUNDS[:box_ok].play
      else
        if @main_color != box.color
          @wrong += 1
          @score += SCORES[:wrong]
          SOUNDS[:box_nok].play
        else
          @correct += 1
          @score += SCORES[:correct]
          SOUNDS[:box_ok].play
        end
      end

      if @boxes.size == 10
        # if all 10 are placed, we'll add extra score if color is unique
        colors = []
        @boxes.each {|box| colors.push box.color}
        if colors.uniq.size == 1
          @score += SCORES[:slice]
          SOUNDS[:pallet_ok].play
        end

        # we reset the pallet
        BoxesGame.main_score += @score
        @boxes = []
        @correct = 0
        @wrong = 0
        @score = 0
        @main_color = nil
      end
    end

    def update
      @boxes.each {|box| box.update}
    end

    def draw
      @boxes.each {|box| box.draw}

      unless @main_color.nil?
        color = case @main_color
        when 'GREEN' then COLORS[:green]
        when 'BLUE' then COLORS[:blue]
        when 'YELLOW' then COLORS[:yellow]
        end

        Gosu.draw_rect(@x + 61, 25, 30, 14, color)
      end
      FONT.draw_text(@correct, @x + 76, 45, 1, 1, 1, Gosu::Color::GREEN)
      FONT.draw_text(@wrong, @x + 61, 62, 1, 1, 1, Gosu::Color::RED)
      FONT.draw_text(@score, @x + 58, 89, 1, 1, 1, Gosu::Color::BLACK)
    end
  end

  class Conveyor
    SPEEDS = [0, 0.5, 1, 4]
    CONTROL_PANEL = [
      Gosu::Image.new("#{BoxesGame::GAME_ROOT_PATH}/gfx/conveyor_control_panel/stop.png", retro: true),
      Gosu::Image.new("#{BoxesGame::GAME_ROOT_PATH}/gfx/conveyor_control_panel/speed_1.png", retro: true),
      Gosu::Image.new("#{BoxesGame::GAME_ROOT_PATH}/gfx/conveyor_control_panel/speed_2.png", retro: true),
      Gosu::Image.new("#{BoxesGame::GAME_ROOT_PATH}/gfx/conveyor_control_panel/speed_3.png", retro: true)
    ]

    def initialize(window, x, y, w, h)
      @window = window
      @x, @y, @w, @h = x, y, w, h
      @ejection_spots = []
      @boxes = []
      @stripe = Gosu::Image.new("#{BoxesGame::GAME_ROOT_PATH}/gfx/conveyor_stripe.png", retro: true)
      @offset_stripe = 0
      @speed = SPEEDS.first
    end

    def set_entry_spot(x, y)
      @entry_spot_x = x
      @entry_spot_y = y
    end

    def add_ejection_spot(x, y, w, h, pallet)
      spot = {x: x, y: y, w: w, h: h, pallet: pallet}
      @ejection_spots.push spot
    end

    def add_box(box)
      # if no box overlaps the entry spot
      if @entry_spot_available
        box.set_destination(@entry_spot_x, @entry_spot_y)
        @boxes.push box
        SOUNDS[:box_placed].play
        return true
      else
        return false
      end
    end

    def remove_box(box)
      @boxes.delete(box)
    end

    def button_down(id)
      if id == Gosu::MS_LEFT
        handle_mouse
      end
      @speed = SPEEDS.first if id == Gosu::KB_TAB
      @speed = SPEEDS[1] if id == Gosu::KB_1
      @speed = SPEEDS[2] if id == Gosu::KB_2
      @speed = SPEEDS[3] if id == Gosu::KB_3
      eject_box(@ejection_spots[0]) if id == Gosu::KB_Q
      eject_box(@ejection_spots[1]) if id == Gosu::KB_W
      eject_box(@ejection_spots[2]) if id == Gosu::KB_E
    end

    def handle_mouse
      @speed = SPEEDS.first if @window.mouse_in?(188, 526, 128, 36)
      @speed = SPEEDS[1] if @window.mouse_in?(58, 526, 36, 36)
      @speed = SPEEDS[2] if @window.mouse_in?(101, 526, 36, 36)
      @speed = SPEEDS[3] if @window.mouse_in?(144, 526, 36, 36)

      @ejection_spots.each do |es|
        if @window.mouse_in?(es[:x], es[:y], es[:w], es[:h])
          eject_box(es)
        end
      end
    end

    def eject_box(es)
      candidates = []
      @boxes.each do |box|
        candidates.push box if box.x + Box::WIDTH >= es[:x] && box.x <= es[:x] + es[:w]
      end

      unless candidates.empty?
        # we push the furthest box to the pallet area
        candidate = candidates.sort {|a, b| a.x <=> b.x}.first
        es[:pallet].add_box(candidate)
        remove_box(candidate)
      end
    end

    def update
      to_delete = []
      @entry_spot_available = @boxes.select {|box| box.x + Box::WIDTH >= @entry_spot_x}.empty?

      @boxes.each do |box|
        if box.state == :on_conveyor
          dest_x = box.x - @speed
          box.set_destination(dest_x, box.y)
        end
        box.update

        # check for out of bounds box
        if box.x + Box::WIDTH <= 0
          SOUNDS[:box_missed].play
          to_delete.push box
          BoxesGame.main_score += MISSED_SCORE
        end
      end

      to_delete.each {|box| @boxes.delete(box)}

      @ejection_spots.each do |es|
        es[:pallet].update
      end

      @offset_stripe -= @speed
      @offset_stripe = 0 if @offset_stripe <= -80.0
    end

    def draw
      # Gosu.draw_rect(@x, @y, @w, @h, Gosu::Color.new(255, 255, 0, 255))
      entry_spot_color = @entry_spot_available ? Gosu::Color::GREEN : Gosu::Color::RED
      Gosu.draw_rect(@entry_spot_x, @entry_spot_y + 1, 48, 47, entry_spot_color)
      @boxes.each {|box| box.draw}

      # ejection spots
      @ejection_spots.each do |es|
        color = Gosu::Color.new(255, 128, 128, 128)
        @boxes.each do |box|
          if box.x + Box::WIDTH >= es[:x] && box.x <= es[:x] + es[:w]
            color = Gosu::Color.new(255, 180, 180, 180)
            break
          end
        end
        Gosu.draw_rect(es[:x], es[:y] + 1, es[:w], es[:h] - 1, color)
      end

      @ejection_spots.each do |es|
        es[:pallet].draw
      end

      # stripes
      10.times do |x|
        @stripe.draw(x * 80 + @offset_stripe, 337, 2)
      end

      # control panel drawing
      CONTROL_PANEL[SPEEDS.index(@speed)].draw(0, 600 - 196, 1)
    end
  end

  class SpawnArea
    def initialize(x, y, w, h)
      @x, @y, @w, @h = x, y, w, h
      @boxes = []
      @boxes_max = 20
      @font = Gosu::Font.new(24)
    end

    def includes_point?(x, y)
      (x >= @x && x <= @x + @w && y >= @y && y <= @y + @h)
    end

    def pick_box(x, y)
      candidates = []
      @boxes.each do |box|
        if box.includes_point?(x, y)
          candidates.push box
        end
      end

      return candidates.empty? ? nil : candidates.sort {|a, b| a.y <=> b.y}.last
    end

    def spawn_box
      return false if @boxes.size + 1 >= @boxes_max
      x = Gosu.random(@x, @x + @w - Box::WIDTH).floor
      y = Gosu.random(@y, @y + @h - Box::HEIGHT).floor
      spawn_x = x
      spawn_y = 10
      box = Box.new(spawn_x, spawn_y)
      box.set_destination(x, y)
      @boxes.push(box)
      SOUNDS[:alert].play(0.25, 0.75) if @boxes.size >= 18
      return true
    end

    def remove_box(box)
      @boxes.delete(box)
    end

    def update
      @boxes.each {|box| box.update}
    end

    def draw
      # Gosu.draw_rect(@x, @y, @w, @h, Gosu::Color::BLUE)
      @boxes.each {|box| box.draw}
      color = @boxes.size >= 18 ? Gosu::Color::RED : Gosu::Color::BLACK
      @font.draw_text("Boxes : #{@boxes.size}/#{@boxes_max}", 660, 45, 2, 1, 1, color)
    end
  end

  class Box
    attr_accessor :x, :y, :state, :color
    WIDTH = 48
    HEIGHT = 32
    @@gfx = Gosu::Image.load_tiles("#{BoxesGame::GAME_ROOT_PATH}/gfx/box.png", WIDTH, HEIGHT, retro: true)
    VELOCITY = 10.0

    def initialize(x, y)
      @x, @y = x, y
      set_destination(@x, @y)
      @box_image = @@gfx.sample
      @color = ['GREEN', 'BLUE', 'YELLOW'][@@gfx.index(@box_image)]
      @states = [:on_truck, :on_spawn, :on_conveyor, :on_pallet]
      @state = :on_truck
    end

    def set_destination(x, y)
      @dest_x, @dest_y = x, y
    end

    def includes_point?(x, y)
      (x >= @x && x <= @x + @box_image.width && y >= @y && y <= @y + @box_image.height)
    end

    def update
      if @x != @dest_x || @y != @dest_y
        if @x > @dest_x
          @x -= VELOCITY
          @x = @dest_x if @x < @dest_x
        end
        if @x < @dest_x
          @x += VELOCITY
          @x = @dest_x if @x > @dest_x
        end
        if @y > @dest_y
          @y -= VELOCITY
          @y = @dest_y if @y < @dest_y
        end
        if @y < @dest_y
          @y += VELOCITY
          @y = @dest_y if @y > @dest_y
        end

        # we reached the next position
        if @x == @dest_x && @y == @dest_y
          if @state == :on_truck
            @state = :on_spawn
          elsif @state == :on_spawn
            @state = :on_conveyor
          end
        end
      end
    end

    def draw
      @box_image.draw(@x, @y, @y)
    end
  end

  class Game
    def initialize(window)
      @state = :title
      @window = window
      @gfx = {
        title: Gosu::Image.new("#{BoxesGame::GAME_ROOT_PATH}/gfx/title.png", retro: true),
        background: Gosu::Image.new("#{BoxesGame::GAME_ROOT_PATH}/gfx/background.png", retro: true),
        tutorial: Gosu::Image.new("#{BoxesGame::GAME_ROOT_PATH}/gfx/tutorial.png", retro: true)
      }

      setup_game

      @font = Gosu::Font.new(48)
      @music = Gosu::Song.new("#{BoxesGame::GAME_ROOT_PATH}/sfx/funbgm102614.ogg")
    end

    def setup_game
      BoxesGame.main_score = 0

      @conveyor = Conveyor.new(@window, 2, 337, 600, 32)
      @conveyor.set_entry_spot(752, 337)
      @conveyor.add_ejection_spot(20, 337, 103, 48, Pallet.new(20, 142, 103, 195))
      @conveyor.add_ejection_spot(197, 337, 103, 48, Pallet.new(197, 142, 103, 195))
      @conveyor.add_ejection_spot(374, 337, 103, 48, Pallet.new(374, 142, 103, 195))

      @spawn_area = SpawnArea.new(800 - 160, 128, 160, 200)
      @boxes_initial_qty = 5
      @boxes_initial_qty.times {@spawn_area.spawn_box}
      @box_tick = Gosu::milliseconds
      @box_time_before_next = 2000
    end

    def button_down(id)
      case @state
      when :title
        # whatever key pressed starts the game
        @state = :tutorial
      when :tutorial
        @state = :game
        @music.play(true)
      when :game
        @conveyor.button_down(id)
        if id == Gosu::MS_LEFT
          handle_mouse
        end
      when :game_over
        # whatever key pressed restarts the game
        setup_game
        @state = :game
      end
    end

    def handle_mouse
      x = @window.mouse_x
      y = @window.mouse_y

      # box picking
      if @spawn_area.includes_point?(x, y)
        box = @spawn_area.pick_box(x, y)
        unless box.nil?
          x = Gosu.random(0, 50)
          y = Gosu.random(0, @window.height - 30)
          # we move the box from spawn to conveyor if space is available on conveyor
          added = @conveyor.add_box(box)
          @spawn_area.remove_box(box) if added
        end
      end
    end

    def auto_spawn
      if Gosu::milliseconds - @box_tick >= @box_time_before_next
        spawn = @spawn_area.spawn_box
        @state = :game_over if spawn == false
        @box_tick = Gosu::milliseconds
      end
    end

    def update
      case @state
      when :game
        auto_spawn
        @spawn_area.update
        @conveyor.update
      end
    end

    def draw
      case @state
      when :title
        @gfx[:title].draw(0, 0, 0)
      when :tutorial
        @gfx[:tutorial].draw(0, 0, 0)
      when :game
        @gfx[:background].draw(0, 0, 0)
        @spawn_area.draw
        @conveyor.draw
        @font.draw_text("Score : #{BoxesGame.main_score}", 460, 500, 1, 1, 1, Gosu::Color::BLACK)
      when :game_over
        @gfx[:background].draw(0, 0, 0)
        @spawn_area.draw
        @conveyor.draw
        Gosu.draw_rect(0, 0, @window.width, @window.height, Gosu::Color.new(128, 0, 0, 0), 10000)
        @font.draw_text('Game Over', 50, 50, 10001, 2, 2, Gosu::Color::WHITE)
        @font.draw_text('Press any key to restart', 50, 140, 10001, 1, 1, Gosu::Color::WHITE)
        @font.draw_text("Score : #{BoxesGame.main_score}", 50, 230, 10001, 2, 2, Gosu::Color::WHITE)
      end
    end
  end

  class Window < Gosu::Window
    def initialize
      super(800, 600, false)
      self.caption = 'Boxes ! - Gosu Game Jam Oct 2021'
      @game = Game.new(self)
    end

    def button_down(id)
      super
      close! if id == Gosu::KB_ESCAPE
      @game.button_down(id)
    end

    def mouse_in?(x, y, w, h)
      (self.mouse_x >= x && self.mouse_x <= x + w && self.mouse_y >= y && self.mouse_y <= y + h)
    end

    def update
      @game.update
    end

    def draw
      @game.draw
    end
  end
end
