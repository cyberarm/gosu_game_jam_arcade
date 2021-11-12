require 'gosu'
require 'wads'
#require 'rdia-games'
require_relative '../lib/rdia-games'

include Wads
include RdiaGames

GAME_WIDTH = 800
GAME_HEIGHT = 700
GAME_START_X = 10
GAME_START_Y = 10

DIRECTION_TOWARDS = 0
DIRECTION_LEFT = 1
DIRECTION_AWAY = 2
DIRECTION_RIGHT = 3

class ScrollerGame < RdiaGame
    def initialize
        super(GAME_WIDTH, GAME_HEIGHT, "Test Scroller", ScrollerDisplay.new)
        register_hold_down_key(Gosu::KbA)    # Move left
        register_hold_down_key(Gosu::KbD)    # Move right
        register_hold_down_key(Gosu::KbW)    # Move left
        register_hold_down_key(Gosu::KbS)    # Move left
    end 
end

class ScrollerDisplay < Widget
    def initialize
        super(0, 0, GAME_WIDTH, GAME_HEIGHT)
        set_layout(LAYOUT_HEADER_CONTENT)
        #set_theme(WadsDarkRedBrownTheme.new)
        disable_border
        @pause = true
        @game_mode = RDIA_MODE_START
        @score = 0
        @level = 1
        @camera_x = 0
        @camera_y = 0

        header_panel = add_panel(SECTION_NORTH)
        header_panel.get_layout.add_text("Test Scroller",
                                         { ARG_TEXT_ALIGN => TEXT_ALIGN_CENTER,
                                           ARG_USE_LARGE_FONT => true})
        subheader_panel = header_panel.get_layout.add_vertical_panel({ARG_LAYOUT => LAYOUT_EAST_WEST,
                                                                      ARG_DESIRED_WIDTH => GAME_WIDTH})
        subheader_panel.disable_border
        west_panel = subheader_panel.add_panel(SECTION_WEST)
        west_panel.get_layout.add_text("Score")
        @score_text = west_panel.get_layout.add_text("#{@score}")
        
        east_panel = subheader_panel.add_panel(SECTION_EAST)
        east_panel.get_layout.add_text("Level", {ARG_TEXT_ALIGN => TEXT_ALIGN_RIGHT})
        @level_text = east_panel.get_layout.add_text("#{@level}",
                                                     {ARG_TEXT_ALIGN => TEXT_ALIGN_RIGHT})
        
        add_overlay(create_overlay_widget)

        @tileset = Gosu::Image.load_tiles("media/basictiles.png", 16, 16, tileable: true)
        @blue_brick = @tileset[1]   # the brick with an empty pixel on the left and right, so there is a gap
        @red_wall = @tileset[7]
        @yellow_dot = @tileset[18]
        @green_dot = @tileset[19]
        @fire_transition_tile = @tileset[66]
        @diagonal_tileset = Gosu::Image.load_tiles("media/diagonaltiles.png", 16, 16, tileable: true)
        @red_wall_se = @diagonal_tileset[0]
        @red_wall_sw = @diagonal_tileset[7]
        @red_wall_nw = @diagonal_tileset[13]
        @red_wall_ne = @diagonal_tileset[10]

        @player = Character.new
        @player.set_absolute_position(400, 150)
        add_child(@player)

        @grid = GridDisplay.new(0, 0, 16, 50, 38, {ARG_SCALE => 2})
        instantiate_elements(File.readlines("./data/scroller_board.txt"))
        add_child(@grid)
    end 

    def draw 
        if @show_border
            draw_border
        end
        @children.each do |child|
            if child.is_a? GridDisplay or child.is_a? Character
                # skip
            else
                child.draw
            end
        end

        Gosu.translate(-@camera_x, -@camera_y) do
            @grid.draw
            @player.draw
        end
    end 

    def handle_update update_count, mouse_x, mouse_y
        # Scrolling follows player
        # @camera_x = [[@cptn.x - WIDTH / 2, 0].max, @map.width * 50 - WIDTH].min
        # @camera_y = [[@cptn.y - HEIGHT / 2, 0].max, @map.height * 50 - HEIGHT].min 
        @camera_x = [[@player.x - (GAME_WIDTH.to_f / 2), 0].max, @grid.grid_width * 32 - GAME_WIDTH].min
        @camera_y = [[@player.y - (GAME_HEIGHT.to_f / 2), 0].max, @grid.grid_height * 32 - GAME_HEIGHT].min
        #puts "#{@player.x}, #{@player.y}    Camera: #{@camera_x}, #{@camera_y}"
    end

    def interact_with_widgets(widgets)
        if widgets.size == 1
            w = widgets[0]
            if w.object_id == @ball.last_element_bounce
                # Don't bounce off the same element twice
                w = nil 
            end
        else 
            # Choose the widget with the shortest distance from the center of the ball
            closest_widget = nil 
            closest_distance = 100   # some large number
            widgets.each do |candidate_widget| 
                d = @ball.distance_between_center_mass(candidate_widget)
                debug("Comparing #{d} with #{closest_distance}. Candidate #{candidate_widget.object_id}  last bounce: #{@ball.last_element_bounce}")
                if d < closest_distance and candidate_widget.object_id != @ball.last_element_bounce
                    closest_distance = d 
                    closest_widget = candidate_widget 
                end 
            end 
            w = closest_widget
        end
        if w.nil?
            return true
        end
        puts "Reaction #{w.interaction_results} with widget #{w}"
        @ball.last_element_bounce = w.object_id
        if w.interaction_results.include? RDIA_REACT_STOP 
            @ball.stop_move
        end
        if w.interaction_results.include? RDIA_REACT_LOSE 
            @pause = true
            @game_mode = RDIA_MODE_END
            if @overlay_widget.nil?
                add_overlay(create_you_lose_widget)
            end
        end
        if w.interaction_results.include? RDIA_REACT_BOUNCE 
            square_bounce(w)
        elsif w.interaction_results.include? RDIA_REACT_BOUNCE_DIAGONAL
            diagonal_bounce(w)
        end
        if w.interaction_results.include? RDIA_REACT_CONSUME
            @grid.remove_tile_at_absolute(w.x + 1, w.y + 1)
        end
        if w.interaction_results.include? RDIA_REACT_GOAL
            # TODO end this round
        end
        if w.interaction_results.include? RDIA_REACT_SCORE
            @score = @score + w.score
            @score_text.label = "#{@score}"
        end
        if w.interaction_results.include? RDIA_REACT_GOAL
            @pause = true
            @game_mode = RDIA_MODE_END
            if @overlay_widget.nil?
                add_overlay(create_you_win_widget)
            end
        end
        true
    end

    def handle_key_held_down id, mouse_x, mouse_y
        if id == Gosu::KbA
            @player.move_left(@grid)
        elsif id == Gosu::KbD
            @player.move_right(@grid)
        elsif id == Gosu::KbW
            @player.move_up(@grid)
        elsif id == Gosu::KbS
            @player.move_down(@grid)
        end
        #puts "#{@player.x}, #{@player.y}    Camera: #{@camera_x}, #{@camera_y}   Tile: #{@grid.tile_at_absolute(@player.x, @player.y)}"
    end

    def handle_key_press id, mouse_x, mouse_y
        if id == Gosu::KbA
            @player.start_move_left 
        elsif id == Gosu::KbD
            @player.start_move_right 
        elsif id == Gosu::KbW
            @player.start_move_up 
        elsif id == Gosu::KbS
            @player.start_move_down
        end
    end

    def handle_key_up id, mouse_x, mouse_y
        if id == Gosu::KbA or id == Gosu::KbD or id == Gosu::KbW or id == Gosu::KbS
            @player.stop_move
        end
    end

    def intercept_widget_event(result)
        info("We intercepted the event #{result.inspect}")
        info("The overlay widget is #{@overlay_widget}")
        if result.close_widget 
            if @game_mode == RDIA_MODE_START
                @game_mode = RDIA_MODE_PLAY
                @pause = false 
            elsif @game_mode == RDIA_MODE_END
                @game_mode = RDIA_MODE_START
            end
        end
        result
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
                puts "[#{index}  #{grid_x},#{grid_y} = #{char}."
                img = nil

                # If the token is a number, use it as the tile index
                if char.match?(/[[:digit:]]/)
                    tile_index = char.to_i
                    puts "Using index #{tile_index}."
                    img = BackgroundArea.new(@tileset[tile_index])
                #elsif char == "B"
                #    img = Brick.new(@blue_brick)
                elsif char == "W"
                    img = Wall.new(@blue_brick)
                elsif char == "Y"
                    img = Dot.new(@yellow_dot)
                elsif char == "G"
                    img = Dot.new(@green_dot)
                elsif char == "F"
                    img = OutOfBounds.new(@fire_transition_tile)
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
end

class Character < GameObject 

    def initialize(args = {})
        @animation_count = 1
        @direction = DIRECTION_TOWARDS
        @character_tileset = Gosu::Image.load_tiles("media/characters.png", 16, 16, tileable: true)
        @img_towards = [@character_tileset[3], @character_tileset[4], @character_tileset[5]]
        @img_left = [@character_tileset[15], @character_tileset[16], @character_tileset[17]]
        @img_right = [@character_tileset[27], @character_tileset[28], @character_tileset[29]]
        @img_away = [@character_tileset[39], @character_tileset[40], @character_tileset[41]]
        @img_array = @img_towards
        super(@img_array[@animation_count])
        disable_border
        @scale = 2     # might need this until we can scale the whole game to 2
        @max_speed = 5
    end

    def handle_update update_count, mouse_x, mouse_y
        if @speed < 0.01
            @img = @img_array[1]
        elsif update_count % 10 == 0    # if we do this every count, you can't even see it
            @animation_count = @animation_count + 1
            if @animation_count > 2
                @animation_count = 0
            end
            @img = @img_array[@animation_count]
        end
    end 

    def stop_move 
        @speed = 0
    end 

    def start_move_right
        @img_array = @img_right
        start_move_in_direction(DEG_0)
        @acceleration = 0
        @speed = 1
    end

    def start_move_left
        @img_array = @img_left
        start_move_in_direction(DEG_180)
        @acceleration = 0
        @speed = 1
    end 

    def start_move_up
        @img_array = @img_away
        start_move_in_direction(DEG_90)
        @acceleration = 0
        @speed = 1
    end

    def start_move_down
        @img_array = @img_towards
        start_move_in_direction(DEG_270)
        @acceleration = 0
        @speed = 1
    end

    def internal_move(grid) 
        if @speed < @max_speed
            speed_up
        end
        player_move(grid)
    end 

    def move_right(grid)
        internal_move(grid) 
    end

    def move_left(grid)
        internal_move(grid)
    end

    def move_up(grid)
        internal_move(grid) 
    end

    def move_down(grid)
        internal_move(grid) 
    end

    def player_move(grid)
        @speed.round.times do
            proposed_next_x, proposed_next_y = proposed_move
            widgets_at_proposed_spot = grid.proposed_widget_at(self, proposed_next_x, proposed_next_y)
            if widgets_at_proposed_spot.empty?
                set_absolute_position(proposed_next_x, proposed_next_y)
            else 
                debug("Can't move any further because widget(s) are there #{widgets_at_proposed_spot}")
            end
        end
    end
end 

class Wall < GameObject
    def initialize(image)
        super(image)
        @can_move = false
    end

    def interaction_results
        [RDIA_REACT_BOUNCE]
    end
end

class Brick < GameObject
    def initialize(image)
        super(image)
        @can_move = false
    end

    def interaction_results
        [RDIA_REACT_BOUNCE, RDIA_REACT_CONSUME, RDIA_REACT_SCORE]
    end

    def score 
        10 
    end
end

class Dot < GameObject
    def initialize(image)
        super(image)
        @can_move = false
    end

    def interaction_results
        [RDIA_REACT_CONSUME, RDIA_REACT_SCORE]
    end

    def score 
        50 
    end
end

class OutOfBounds < GameObject
    def initialize(image)
        super(image)
        @can_move = false
    end

    def interaction_results
        [RDIA_REACT_LOSE, RDIA_REACT_STOP]
    end
end

class BackgroundArea < GameObject
    def initialize(image)
        super(image)
        @can_move = false
    end

    def widget_z
        Z_ORDER_SELECTION_BACKGROUND
    end
end

class ForegroundArea < GameObject
    def initialize(image)
        super(image)
        @can_move = false
    end

    def widget_z
        Z_ORDER_TEXT
    end
end

class GoalArea < GameObject
    def initialize(image)
        super(image)
        @can_move = false
    end

    def interaction_results
        [RDIA_REACT_GOAL, RDIA_REACT_STOP]
    end
end

class BricksTheme < GuiTheme
    def initialize
        super(COLOR_WHITE,                # text color
              COLOR_HEADER_BRIGHT_BLUE,   # graphic elements
              COLOR_BORDER_BLUE,          # border color
              COLOR_BLACK,                # background
              COLOR_LIGHT_GRAY,           # selected item
              true,                       # use icons
              Gosu::Font.new(22, {:name => media_path("armalite_rifle.ttf")}),  # regular font
              Gosu::Font.new(38, {:name => media_path("armalite_rifle.ttf")}))  # large font
    end

    def media_path(file)
        File.join(File.dirname(File.dirname(__FILE__)), 'media', file)
    end
end


def create_overlay_widget
    InfoBox.new(100, 60, 600, 400, "Welcome to Ruby Bricks", overlay_content, { ARG_THEME => BricksTheme.new})
end

def overlay_content
    <<~HEREDOC
    Your goal is to clear all of the bricks and dots
    without letting the ball drop through to the bottom.
    Hit the 'W' button to get started.
    HEREDOC
end

def create_you_lose_widget
    InfoBox.new(100, 60, 600, 400, "Sorry, you lost", you_lose_content, { ARG_THEME => BricksTheme.new})
end

def you_lose_content
    <<~HEREDOC
    Try not to let the ball fall through next time.
    HEREDOC
end

def create_you_win_widget
    InfoBox.new(100, 60, 600, 400, "You win!", you_win_content, { ARG_THEME => WadsDarkRedBrownTheme.new})
end

def you_win_content
    <<~HEREDOC
    You did it. That was amazing!
    Nice work.
    HEREDOC
end
WadsConfig.instance.set_current_theme(BricksTheme.new)


ScrollerGame.new.show
