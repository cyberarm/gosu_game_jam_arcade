require 'gosu'
require 'wads'
#require 'rdia-games'
require_relative '../lib/rdia-games'

include Wads
include RdiaGames

SCREEN_WIDTH = 640
SCREEN_HEIGHT = 480

MAP_WIDTH = 24
MAP_HEIGHT = 24

class RayCaster 
    def initialize(world_map, screen_width, screen_height)
        @world_map = world_map
        @w = screen_width
        @h = screen_height
    end 

    def ray(x, posX, posY, dirX, dirY, planeX, planeY)
        # calculate ray position and direction
        cameraX = (2 * (x / @w.to_f)) - 1;   # x-coordinate in camera space
        rayDirX = dirX + (planeX * cameraX)
        rayDirY = dirY + (planeY * cameraX)
        # which box of the map we're in
        mapX = posX.to_i
        mapY = posY.to_i

        # length of ray from current position to next x or y-side: sideDistX, sideDistY
          
        # length of ray from one x or y-side to next x or y-side
        # these are derived as:
        # deltaDistX = sqrt(1 + (rayDirY * rayDirY) / (rayDirX * rayDirX))
        # deltaDistY = sqrt(1 + (rayDirX * rayDirX) / (rayDirY * rayDirY))
        # which can be simplified to abs(|rayDir| / rayDirX) and abs(|rayDir| / rayDirY)
        # where |rayDir| is the length of the vector (rayDirX, rayDirY). Its length,
        # unlike (dirX, dirY) is not 1, however this does not matter, only the
        # ratio between deltaDistX and deltaDistY matters, due to the way the DDA
        # stepping further below works. So the values can be computed as below.
        # Division through zero is prevented, even though technically that's not
        # needed in C++ with IEEE 754 floating point values.
        deltaDistX = (rayDirX == 0) ? 1e30 : (1 / rayDirX).abs
        deltaDistY = (rayDirY == 0) ? 1e30 : (1 / rayDirY).abs
          
        perpWallDist = nil    # double
          
        # what direction to step in x or y-direction (either +1 or -1)
        stepX = nil    # int
        stepY = nil    # int

                  
        hit = 0        # was there a wall hit? (int) (is this really a boolean)
        side = nil     # was a NS or a EW wall hit? (int) (is this really a boolean)
        # calculate step and initial sideDist
        if rayDirX < 0
            stepX = -1
            sideDistX = (posX - mapX) * deltaDistX
        else
            stepX = 1
            sideDistX = (mapX + 1.0 - posX) * deltaDistX
        end
        if rayDirY < 0
            stepY = -1
            sideDistY = (posY - mapY) * deltaDistY
        else
            stepY = 1;
            sideDistY = (mapY + 1.0 - posY) * deltaDistY
        end
        # perform DDA
        while hit == 0
            # jump to next map square, either in x-direction, or in y-direction
            if sideDistX < sideDistY
                sideDistX += deltaDistX
                mapX += stepX
                side = 0
            else
                sideDistY += deltaDistY
                mapY += stepY
                side = 1
            end
            # Check if ray has hit a wall
            if @world_map[mapX][mapY] > 0
                hit = 1
            end
        end

        # Calculate distance projected on camera direction. This is the shortest distance from the point where the wall is
        # hit to the camera plane. Euclidean to center camera point would give fisheye effect!
        # This can be computed as (mapX - posX + (1 - stepX) / 2) / rayDirX for side == 0, or same formula with Y
        # for size == 1, but can be simplified to the code below thanks to how sideDist and deltaDist are computed:
        # because they were left scaled to |rayDir|. sideDist is the entire length of the ray above after the multiple
        # steps, but we subtract deltaDist once because one step more into the wall was taken above.
        if side == 0
            perpWallDist = (sideDistX - deltaDistX)
        else
            perpWallDist = (sideDistY - deltaDistY)
        end

        # Calculate height of line to draw on screen
        lineHeight = (@h / perpWallDist).to_i

        # calculate lowest and highest pixel to fill in current stripe
        drawStart = ((-lineHeight / 2) + (@h / 2)).to_i
        if drawStart < 0
            drawStart = 0
        end
        drawEnd = ((lineHeight / 2) + (@h / 2)).to_i
        if drawEnd >= @h
            drawEnd = @h - 1
        end
        
        [drawStart, drawEnd, mapX, mapY, side]
    end
end

class RaycasterGame < RdiaGame
    def initialize
        super(SCREEN_WIDTH, SCREEN_HEIGHT, "Raycaster", RaycasterDisplay.new)
        register_hold_down_key(Gosu::KbA)    # Move left
        register_hold_down_key(Gosu::KbD)    # Move right
        register_hold_down_key(Gosu::KbW)    # Move left
        register_hold_down_key(Gosu::KbS)    # Move left
    end 
end

class RaycasterDisplay < Widget
    def initialize
        super(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)
        disable_border
        @pause = true

        # Start raycaster code
        @posX = 22     # x and y start position
        @posY = 12  
        @dirX = -1     # initial direction vector
        @dirY = 0   
        @planeX = 0     # the 2d raycaster version of camera plane
        @planeY = 0.66 

        @time = 0       # time of current frame
        @oldTime = 0    # time of previous frame

        # zero's in the grid are empty space, so basicly you see a very big room,
        # with a wall around it (the values 1),
        # a small room inside it (the values 2),
        # a few pilars (the values 3),
        # and a corridor with a room (the values 4).
        @worldMap = [
          [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1],
          [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
          [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
          [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
          [1,0,0,0,0,0,2,2,2,2,2,0,0,0,0,3,0,3,0,3,0,0,0,1],
          [1,0,0,0,0,0,2,0,0,0,2,0,0,0,0,0,0,0,0,0,0,0,0,1],
          [1,0,0,0,0,0,2,0,0,0,2,0,0,0,0,3,0,0,0,3,0,0,0,1],
          [1,0,0,0,0,0,2,0,0,0,2,0,0,0,0,0,0,0,0,0,0,0,0,1],
          [1,0,0,0,0,0,2,2,0,2,2,0,0,0,0,3,0,3,0,3,0,0,0,1],
          [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
          [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
          [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
          [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
          [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
          [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
          [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
          [1,4,4,4,4,4,4,4,4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
          [1,4,0,4,0,0,0,0,4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
          [1,4,0,0,0,0,5,0,4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
          [1,4,0,4,0,0,0,0,4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
          [1,4,0,4,4,4,4,4,4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
          [1,4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
          [1,4,4,4,4,4,4,4,4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
          [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1]
        ]     
        @raycaster = RayCaster.new(@worldMap, SCREEN_WIDTH, SCREEN_HEIGHT)
    end

    def draw 
        @vertical_lines.each do |line|
            line.draw 
        end 
    end 

    def handle_update update_count, mouse_x, mouse_y
        # The raycasting loop is a for loop that goes through every x,
        # so there isn't a calculation for every pixel of the screen,
        # but only for every vertical stripe, which isn't much at all!
        @vertical_lines = []
        w = SCREEN_WIDTH 
        h = SCREEN_HEIGHT
        (0..w).each do |x|

            drawStart, drawEnd, mapX, mapY, side = @raycaster.ray(x, @posX, @posY, @dirX, @dirY, @planeX, @planeY)
           
            # choose wall color
            color = nil   # rgb
            case @worldMap[mapX][mapY]
            when 1
                color = Gosu::Color.new(255, 255, 0, 0)
            when 2
                color = Gosu::Color.new(255, 0, 255, 0)
            when 3
                color = Gosu::Color.new(255, 0, 0, 255)
            when 4
                color = Gosu::Color.new(255, 255, 255, 255)
            else
                color = COLOR_YELLOW
            end
          
            # give x and y sides different brightness
            # TODO be able to modify the color brightness
            if side == 1
                color = Gosu::Color.new(255, color.red / 2, color.green / 2, color.blue / 2)
            end
          
            # draw the pixels of the stripe as a vertical line
            @vertical_lines << Line.new(x, drawStart, x, drawEnd, color)
        end  # end of the for x loop

        # timing for input and FPS counter
        @oldTime = @time
        @time = update_count
        # frameTime is the time this frame has taken, in seconds
        frameTime = (@time - @oldTime) / 60.0
        if frameTime < 0.016666666666666666
            puts "FPS below 60:  #{1.0 / frameTime}"
        end
        @moveSpeed = frameTime * 5.0   # the constant value is in squares/second
        @rotSpeed = frameTime * 3.0   # the constant value is in radians/second
    end


    def handle_key_held_down id, mouse_x, mouse_y
        handle_movement id, mouse_x, mouse_y
    end

    def handle_key_press id, mouse_x, mouse_y
        handle_movement id, mouse_x, mouse_y
    end

    def handle_movement id, mouse_x, mouse_y
        if id == Gosu::KbW
            if @worldMap[(@posX + @dirX * @moveSpeed).to_i][@posY.to_i] == 0
                @posX += @dirX * @moveSpeed
            end
            if @worldMap[@posX.to_i][(@posY + @dirY * @moveSpeed).to_i] == 0
                @posY += @dirY * @moveSpeed
            end

        elsif id == Gosu::KbS 
            if @worldMap[(@posX - @dirX * @moveSpeed).to_i][@posY.to_i] == 0
                @posX -= @dirX * @moveSpeed
            end
            if @worldMap[@posX.to_i][(@posY - @dirY * @moveSpeed).to_i] == 0
                @posY -= @dirY * @moveSpeed
            end
             
        elsif id == Gosu::KbD
            # both camera direction and camera plane must be rotated
            oldDirX = @dirX.to_f
            @dirX = @dirX * Math.cos(-@rotSpeed) - @dirY * Math.sin(-@rotSpeed)
            @dirY = oldDirX * Math.sin(-@rotSpeed) + @dirY * Math.cos(-@rotSpeed)
            oldPlaneX = @planeX.to_f
            @planeX = @planeX * Math.cos(-@rotSpeed) - @planeY * Math.sin(-@rotSpeed)
            @planeY = oldPlaneX * Math.sin(-@rotSpeed) + @planeY * Math.cos(-@rotSpeed)

        elsif id == Gosu::KbA
            # both camera direction and camera plane must be rotated
            oldDirX = @dirX.to_f
            @dirX = @dirX * Math.cos(@rotSpeed) - @dirY * Math.sin(@rotSpeed)
            @dirY = oldDirX * Math.sin(@rotSpeed) + @dirY * Math.cos(@rotSpeed)
            oldPlaneX = @planeX.to_f
            @planeX = @planeX * Math.cos(@rotSpeed) - @planeY * Math.sin(@rotSpeed)
            @planeY = oldPlaneX * Math.sin(@rotSpeed) + @planeY * Math.cos(@rotSpeed)
        end
    end

    def handle_key_up id, mouse_x, mouse_y
        # Nothing to do
    end

    def intercept_widget_event(result)
        info("We intercepted the event #{result.inspect}")
        info("The overlay widget is #{@overlay_widget}")
        result
    end
end

RaycasterGame.new.show
