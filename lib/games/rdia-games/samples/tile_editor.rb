require 'gosu'
require 'wads'
#require 'rdia-games'
require_relative '../lib/rdia-games'

include Wads
include RdiaGames

GAME_WIDTH = 1280
GAME_HEIGHT = 720


class TileEditor < RdiaGame
    def initialize(board_file = "./data/editor_board.txt")
        super(GAME_WIDTH, GAME_HEIGHT, "TileEditor", TileEditorDisplay.new(board_file))
        register_hold_down_key(Gosu::KbA)    # Move left
        register_hold_down_key(Gosu::KbD)    # Move right
        register_hold_down_key(Gosu::KbW)    # Move left
        register_hold_down_key(Gosu::KbS)    # Move left
    end 
end

class TileEditorDisplay < Widget
    def initialize(board_file)
        super(0, 0, GAME_WIDTH, GAME_HEIGHT)
        disable_border
        @camera_x = 0
        @camera_y = 0

        @center_x = 0   # this is what the buttons will cause to move
        @center_y = 0
        @speed = 4

        @mouse_dragging = false
        @use_eraser = false

        @current_mouse_text = Text.new(10, 700, "0, 0")
        add_child(@current_mouse_text)

        @selected_tile = nil

        @tileset = Gosu::Image.load_tiles("media/basictiles.png", 16, 16, tileable: true)
        @diagonal_tileset = Gosu::Image.load_tiles("media/diagonaltiles.png", 16, 16, tileable: true)

        #@grid = GridDisplay.new(0, 0, 16, 50, 38, {ARG_SCALE => 2})
        @grid = GridDisplay.new(0, 0, 16, 21, 95)
        instantiate_elements(File.readlines(board_file))
        add_child(@grid)

        @pallette = TilePalletteDisplay.new 
        add_child(@pallette)

        add_text("Current Tile:", 900, 630)

        add_button("Use Eraser", 940, 680, 120) do
            if @use_eraser 
                @use_eraser = false 
            else 
                @use_eraser = true
                WidgetResult.new(false)
            end
        end

        add_button("Clear", 1080, 680, 120) do
            (1..@grid.grid_height-3).each do |y|
                (1..@grid.grid_width-2).each do |x|
                    @grid.remove_tile(x, y)
                end 
            end
            WidgetResult.new(false)
        end

        # highlight the key tiles we use
        # the rest are background
        add_shadow_box(5)
        add_shadow_box(18)
        add_shadow_box(19)
        add_shadow_box(38)
        add_shadow_box(59)
        add_shadow_box(64)
        add_shadow_box(66)
    end 

    def add_shadow_box(tile_index)
        x, y = @pallette.get_coords_for_index(tile_index)
        # Draw a box that extends past the widget, because the tile can cover the whole box
        shadow_box = Widget.new(@pallette.x + x - 5, @pallette.y + y - 5, 42, 42)
        shadow_box.set_theme(WadsAquaTheme.new)
        shadow_box.set_selected
        shadow_box.disable_border
        add_child(shadow_box)
    end

    def draw 
        @children.each do |child|
            if child.is_a? GridDisplay
                # skip
            else
                child.draw
            end
        end

        if @selected_tile
            @selected_tile.draw 
        end

        Gosu.translate(-@camera_x, -@camera_y) do
            @grid.draw
        end
    end 

    def handle_update update_count, mouse_x, mouse_y
        # Scrolling follows player
        # @camera_x = [[@cptn.x - WIDTH / 2, 0].max, @map.width * 50 - WIDTH].min
        # @camera_y = [[@cptn.y - HEIGHT / 2, 0].max, @map.height * 50 - HEIGHT].min 
        @camera_x = [[@center_x - (GAME_WIDTH.to_f / 2), 0].max, @grid.grid_width * 64 - GAME_WIDTH].min
        @camera_y = [[@center_y - (GAME_HEIGHT.to_f / 2), 0].max, @grid.grid_height * 16 - GAME_HEIGHT].min

        @current_mouse_text.label = "cen: #{@center_x}, #{@center_y}  cam: #{@camera_x}, #{@camera_y}  mou: #{mouse_x}, #{mouse_y}   "

        if @mouse_dragging and @grid.contains_click(mouse_x, mouse_y)
            grid_x = @grid.determine_grid_x(mouse_x)
            grid_y = @grid.determine_grid_y(mouse_y)
            #puts "The mouse is dragging through tile #{grid_x}, #{grid_y}"
            if @use_eraser 
                @grid.remove_tile(grid_x, grid_y)
            elsif @selected_tile
                new_tile = PalletteTile.new(@grid.grid_to_relative_pixel(grid_x),
                                            @grid.grid_to_relative_pixel(grid_y),
                                            @selected_tile.img,
                                            1,   # scale
                                            @selected_tile.index)
                @grid.set_tile(grid_x, grid_y, new_tile)
            end
        end
    end

    def handle_key_held_down id, mouse_x, mouse_y
        if id == Gosu::KbA
            @center_x = @center_x - @speed
        elsif id == Gosu::KbD
            @center_x = @center_x + @speed
        elsif id == Gosu::KbW
            @center_y = @center_y - @speed
        elsif id == Gosu::KbS
            @center_y = @center_y + @speed
        end
        puts "moved center to #{@center_x}, #{@center_y}"
    end

    def handle_key_press id, mouse_x, mouse_y
        if id == Gosu::KbA
            @center_x = @center_x - @speed
        elsif id == Gosu::KbD
            @center_x = @center_x + @speed
        elsif id == Gosu::KbW
            @center_y = @center_y - @speed
        elsif id == Gosu::KbS
            @center_y = @center_y + @speed
        elsif id == Gosu::KbP
            save_board
        elsif id == Gosu::KbG
            @grid.display_grid = !@grid.display_grid
        end
    end

    def handle_key_up id, mouse_x, mouse_y
        #if id == Gosu::KbA or id == Gosu::KbD or id == Gosu::KbW or id == Gosu::KbS
        #    @player.stop_move
        #end
    end

    def handle_mouse_down mouse_x, mouse_y
        @mouse_dragging = true
        @pallette.children.each do |pi|
            if pi.contains_click(mouse_x, mouse_y)
                @selected_tile = PalletteTile.new(1100, 630, pi.img, 1, pi.index)
            end 
        end
        if @grid.contains_click(mouse_x, mouse_y)
            # Calculate which grid square this is
            # In the future with scrolling, we will need to consider CenterX
            # but for now without scrolling, its a simple calculation
            grid_x = @grid.determine_grid_x(mouse_x)
            grid_y = @grid.determine_grid_y(mouse_y)
            #puts "We have a selcted tile. Click was on #{grid_x}, #{grid_y}"
            if @use_eraser 
                @grid.remove_tile(grid_x, grid_y)
            elsif @selected_tile
                new_tile = PalletteTile.new(@grid.grid_to_relative_pixel(grid_x),
                                            @grid.grid_to_relative_pixel(grid_y),
                                            @selected_tile.img,
                                            1,   # scale
                                            @selected_tile.index)
                @grid.set_tile(grid_x, grid_y, new_tile)
            end
        end
        #return WidgetResult.new(false)
    end

    def handle_mouse_up mouse_x, mouse_y
        @mouse_dragging = false
    end


    # Takes an array of strings that represents the board
    def instantiate_elements(dsl)         
        @grid.clear_tiles
        grid_y = 0
        grid_x = 0
        dsl.each do |line|
            index = 0
            while index < line.size
                char = line[index..index+1].strip
                #puts "[#{index}]  #{grid_x},#{grid_y} = #{char}."
                img = nil

                # If the token is a number, use it as the tile index
                if char.match?(/[[:digit:]]/)
                    tile_index = char.to_i
                    #puts "Using index #{tile_index}."
                    img = PalletteTile.new(0, 0, @tileset[tile_index], 1, tile_index)
                end
                
                if img.nil?
                    # nothing to do
                else
                    @grid.set_tile(grid_x, grid_y, img)
                end

                grid_x = grid_x + 1
                index = index + 2
            end
            grid_x = 0
            grid_y = grid_y + 1
        end
    end 

    def save_board 
        puts "Going to save board"
        open("./data/editor_new_board.txt", 'w') { |f|
            (0..@grid.grid_height-1).each do |y|
                str = ""
                (0..@grid.grid_width-1).each do |x|
                    pallette_tile = @grid.get_tile(x, y)
                    if pallette_tile.nil?
                        str = "#{str}. "
                    else
                        if pallette_tile.index.to_i < 10
                            str = "#{str}#{pallette_tile.index} "
                        else
                            str = "#{str}#{pallette_tile.index}"
                        end
                    end
                end
                f.puts str
            end
        }
    end
end

class PalletteTile < ImageWidget 
    attr_accessor :index
    def initialize(x, y, image, scale, index)
        super(x, y, image)
        set_dimensions(32, 32)
        @index = index 
        @scale = scale
    end

    def handle_mouse_down mouse_x, mouse_y
        puts "In #{@index}, checking for click"
        if contains_click(mouse_x, mouse_y)
            puts "Got it #{@index}"
            return WidgetResult.new(false, "select", self)
        end
    end
end 

class TilePalletteDisplay < Widget
    def initialize
        super(900, 10, 360, 600)
        #disable_border
        determineTileCords
        addPalletteItems
    end 

    def determineTileCords
        tempX = 10
        tempY = 10
        tempCounter = 0
        tileQuantity = 100
        @tileCords = []
        tileQuantity.times do
            @tileCords += [[tempX, tempY, tempCounter]]
            tempX += 40
            tempCounter += 1
            if tempX > 310
                tempX = 10
                tempY += 40
            end
        end
    end

    def get_coords_for_index(index)
        @tileCords.each do |x, y, order|
            if order == index 
                # We found it
                return [x, y]
            end 
        end 
        raise "Pallette display does not have tile with index #{index}"
    end

    def addPalletteItems 
        @tileCords.map do |x, y, order|
            add_child(PalletteTile.new(@x + x, @y + y, "./media/tile#{order.to_s}.png", 2, order))
        end
    end
end

if ARGV.size == 0
    puts "No args provided"
    TileEditor.new.show
elsif ARGV.size == 1
    puts "A board filename arg was provided"
    TileEditor.new(ARGV[0]).show
else 
    puts "Too many args provided"
    exit
end
