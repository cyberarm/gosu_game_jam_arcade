require 'gosu'
require 'wads'
#require 'rdia-games'
require_relative '../lib/rdia-games'

include Wads
include RdiaGames

WORLD_X_START = -1000
WORLD_X_END = 1000
WORLD_Z_START = -500
WORLD_Z_END = 9000

GAME_WIDTH = 1280
GAME_HEIGHT = 720

MODE_ISOMETRIC = "iso"
MODE_REAL_THREE_D = "real3d"

AXIS_BEGIN = -500
AXIS_END = 500

class Point 
    attr_accessor :x
    attr_accessor :y
    def initialize(x, y)
        @x = x 
        @y = y 
    end
    def to_s 
        "Point #{x}, #{y}"
    end
end 

class IntersectionLine
    attr_reader :a, :b
   
    def initialize(point1, point2)
      @a = (point1.y - point2.y).fdiv(point1.x - point2.x)
      @b = point1.y - @a*point1.x
    end
   
    def intersect(other)
      return nil if @a == other.a
      x = (other.b - @b).fdiv(@a - other.a)
      y = @a*x + @b
      Point.new(x,y)
    end
   
    def to_s
      "y = #{@a}x + #{@b}"
    end   
end

class PointInsidePolygon
    # check if a given point lies inside a given polygon
    # Refer https://www.geeksforgeeks.org/check-if-two-given-line-segments-intersect/
    # for explanation of functions onSegment(),
    # orientation() and doIntersect()
     
    # Define Infinite (Using INT_MAX caused overflow problems)
    INF = 100000
     
    # Given three collinear points p, q, r,
    # the function checks if point q lies
    # on line segment 'pr'
    def onSegment(point, q, r)
        #puts "onSgement q.x <= [point.x, r.x].max   #{q.x <= [point.x, r.x].max}"
        #puts "onSgement q.x >= [point.x, r.x].min   #{q.x >= [point.x, r.x].min}"
        #puts "  q.x: #{q.x}  point.x: #{point.x}   r.x: #{r.x}  min #{[point.x, r.x].min}"
        #puts "onSgement q.y <= [point.y, r.y].max   #{q.y <= [point.y, r.y].max}"
        #puts "onSgement q.y >= [point.y, r.y].min   #{q.y >= [point.y, r.y].min}"
        if q.x <= [point.x, r.x].max and
           q.x >= [point.x, r.x].min and
           q.y <= [point.y, r.y].max and
           q.y >= [point.y, r.y].min
            return true
        end
        false
    end
     
    # To find orientation of ordered triplet (p, q, r).
    # The function returns following values
    # 0 --> p, q and r are collinear
    # 1 --> Clockwise
    # 2 --> Counterclockwise
    def orientation(point, q, r)
        val = (q.y - point.y) * (r.x - q.x) - (q.x - point.x) * (r.y - q.y)
    
        if val == 0
            return 0  # collinear
        end
        return (val > 0) ? 1 : 2  # clock or counterclock wise
    end
     
    # The function that returns true if
    # line segment 'p1q1' and 'p2q2' intersect.
    def doIntersect(p1, q1, p2, q2)
        # Find the four orientations needed for
        # general and special cases
        o1 = orientation(p1, q1, p2)   # these are ints
        o2 = orientation(p1, q1, q2)
        o3 = orientation(p2, q2, p1)
        o4 = orientation(p2, q2, q1)
     
        # General case
        if (o1 != o2 and o3 != o4)
            return true
        end
     
        # Special Cases
        # p1, q1 and p2 are collinear and
        # p2 lies on segment p1q1
        if o1 == 0 and onSegment(p1, p2, q1)
            return true
        end
     
        # p1, q1 and p2 are collinear and
        # q2 lies on segment p1q1
        if o2 == 0 and onSegment(p1, q2, q1)
            return true
        end
     
        # p2, q2 and p1 are collinear and
        # p1 lies on segment p2q2
        if o3 == 0 and onSegment(p2, p1, q2)
            return true
        end
     
        # p2, q2 and q1 are collinear and
        # q1 lies on segment p2q2
        if o4 == 0 and onSegment(p2, q1, q2)
            return true
        end
     
        # Doesn't fall in any of the above cases
        return false
    end
     
    # Returns true if the point p lies
    # inside the polygon[] with n vertices
    # isInside(Point polygon[], int n, Point p)
    def isInside(polygon, n, point)
        # There must be at least 3 vertices in polygon[]
        if (n < 3)
            return false
        end
     
        # Create a point for line segment from p to infinite
        extreme = Point.new(INF, point.y)
     
        # Count intersections of the above line
        # with sides of polygon
        count = 0    # int
        i = 0        # int
        loop do
            next_int = (i + 1) % n
            #puts "next_int: #{next_int}   i: #{i}"
    
            # Check if the line segment from 'p' to
            # 'extreme' intersects with the line
            # segment from 'polygon[i]' to 'polygon[next]'
            #puts "Checking intersect [#{polygon[i]}, #{polygon[next_int]}], [#{point}, #{extreme}]"
            if doIntersect(polygon[i], polygon[next_int], point, extreme)
                #puts "#{i} did intersect"
                # If the point 'p' is collinear with line
                # segment 'i-next', then check if it lies
                # on segment. If it lies, return true, otherwise false
                if orientation(polygon[i], point, polygon[next_int]) == 0
                    #puts "#{i} was colinear"
                    return onSegment(polygon[i], point, polygon[next_int])
                end
    
                count = count + 1
            #else 
            #    puts "#{i} no intersect"
            end
            i = next_int
            break if i == 0
        end
    
        # Return true if count is odd, false otherwise
        #puts "returning (count % 2 == 1) for count #{count}"
        return (count % 2 == 1)  # Same as (count%2 == 1)
    end
     
    # This code is contributed by 29AjayKumar
end 

class RayCastData 
    attr_accessor :x
    attr_accessor :tile_x
    attr_accessor :tile_y 
    attr_accessor :map_x
    attr_accessor :map_y 
    attr_accessor :at_ray 
    attr_accessor :side
    attr_accessor :draw_start  
    attr_accessor :draw_end 
    attr_accessor :color 
    attr_accessor :orig_map_x 
    attr_accessor :orig_map_y

    def initialize(x, tile_x, tile_y, map_x, map_y, at_ray, side, draw_start, draw_end, color, orig_map_x, orig_map_y)
        @x = x 
        @tile_x = tile_x 
        @tile_y = tile_y
        @map_x = map_x 
        @map_y = map_y 
        @at_ray = at_ray 
        @side = side 
        @draw_start = draw_start 
        @draw_end = draw_end
        @color = color
        @orig_map_x = orig_map_x 
        @orig_map_y = orig_map_y
    end

    def slope
        [@map_y - @orig_map_y, @map_x - @orig_map_x]
    end 

    def quad_from_slope
        # Return the side of impact on the viewed shape from the ray
        slope_x, slope_y = slope
        if slope_x > 0
            if slope_y > 0
                return QUAD_SW
            elsif slope_y == 0
                return QUAD_W
            else 
                return QUAD_NW
            end
        elsif slope_x == 0
            if slope_y > 0
                return QUAD_S
            else 
                return QUAD_N
            end 
        else 
            # slope_x < 0
            if slope_y > 0
                return QUAD_SE
            elsif slope_y == 0
                return QUAD_E
            else 
                return QUAD_NE
            end
        end

        # Do not know or x and y equal, so we are on top of the object
        # and therefore should not display it
        QUAD_NONE
    end

    def to_s 
        "Ray x: #{@x} Tile[#{@tile_x}, #{@tile_y}] -> Map[#{@map_y}, #{@map_x}]  At: #{@at_ray}  Side: #{@side}"
    end 
end
    
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

        orig_map_x = mapX
        orig_map_y = mapY

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
            #puts "#{mapY - 10}, #{mapX - 5}  #{sideDistY}, #{sideDistX}  hit: #{hit}  side: #{side}  orig: #{orig_map_y - 10}, #{orig_map_x - 5}"
        end

        # Calculate distance projected on camera direction. This is the shortest distance from the point where the wall is
        # hit to the camera plane. Euclidean to center camera point would give fisheye effect!
        # This can be computed as (mapX - posX + (1 - stepX) / 2) / rayDirX for side == 0, or same formula with Y
        # for size == 1, but can be simplified to the code below thanks to how sideDist and deltaDist are computed:
        # because they were left scaled to |rayDir|. sideDist is the entire length of the ray above after the multiple
        # steps, but we subtract deltaDist once because one step more into the wall was taken above.
        #if side == 0
        #    perpWallDist = (sideDistX - deltaDistX)
        #else
        #    perpWallDist = (sideDistY - deltaDistY)
        #end

        # Calculate height of line to draw on screen
        #lineHeight = (@h / perpWallDist).to_i

        # calculate lowest and highest pixel to fill in current stripe
        #drawStart = ((-lineHeight / 2) + (@h / 2)).to_i
        #if drawStart < 0
        #    drawStart = 0
        #end
        #drawEnd = ((lineHeight / 2) + (@h / 2)).to_i
        #if drawEnd >= @h
        #    drawEnd = @h - 1
        #end
        
        #[drawStart, drawEnd, mapX, mapY, side, orig_map_x, orig_map_y]
        [0, 0, mapX, mapY, side, orig_map_x, orig_map_y]
    end
end

class ThreeDPoint
    attr_accessor :x
    attr_accessor :y 
    attr_accessor :z 

    def initialize(x, y, z) 
        @x = x 
        @y = y 
        @z = z
    end

    def to_s 
        "#{@x.round},#{@y.round},#{@z.round}"
    end
end

class ThreeDObject 
    attr_accessor :model_points
    attr_accessor :render_points
    attr_accessor :angle_x
    attr_accessor :angle_y
    attr_accessor :angle_z
    attr_accessor :speed
    attr_accessor :color
    attr_accessor :visible
    attr_accessor :visible_side
    attr_accessor :scale
    attr_accessor :is_external
    attr_accessor :render_z_order

    def initialize(color = COLOR_AQUA)
        @move_x = 0     # TODO make public?
        @move_y = 0     # TODO make public?
        clear_points 
        reset_angle_and_scale
        @color = color
        @visible = true
        @draw_as_image = true
        @scale = 1
        @render_z_order = Z_ORDER_BORDER
    end 

    def reset_visible_side
        if @is_external
            # do nothing, the visibility is static for external walls
        else
            @visible_side = QUAD_ALL
            if @color == COLOR_RED
                @color = COLOR_AQUA
            end
        end
    end 

    def set_visible_side(val)
        if @visible_side.nil?
            @visible_side = val 
        elsif val != @visible_side 
            if @visible_side != 0
                puts "ERROR the visible side changing from #{@visible_side} to #{val}"
            end
            @visible_side = val  
        end 
    end

    def is_behind_us
        # This is a hack, but somewhat effective
        (0..@render_points.size-1).each do |n|
            if @render_points[n].y < -10
                if self.is_a? ThreeDLine
                    #puts "Not displaying a line #{self.to_s}"
                end
                if self.is_a? Wall 
                    #puts "Not drawing a wall"
                end
                @visible = false
                return true 
            end
        end
        
        #elsif @model_points[1].z > $camera_z
        #    puts "Not displaying line because 1 point z #{@render_points[1].z} > #{$camera_z}"
        @visible = true
        false
    end

    def a
        @render_points[0]
    end 
    def b
        @render_points[1]
    end 
    def c
        @render_points[2]
    end 
    def d 
        @render_points[3]
    end 
    def e
        @render_points[4]
    end 
    def f
        @render_points[5]
    end 
    def g
        @render_points[6]
    end 
    def h
        @render_points[7]
    end

    def clear_points 
        @model_points = []
        @render_points = []
    end

    def reset_angle_and_scale 
        @angle_x = 0
        @angle_y = 0
        @angle_z = 0
        @scale = 0.001
    end

    def move_left 
        @model_points.each do |model_point|
            model_point.x = model_point.x - 5
        end
    end 
    def move_right 
        @model_points.each do |model_point|
            model_point.x = model_point.x + 5
        end
    end 
    def move_up 
        @model_points.each do |model_point|
            model_point.y = model_point.y - 5
        end
    end 
    def move_down
        @model_points.each do |model_point|
            model_point.y = model_point.y + 5
        end
    end 
    def move_away
        @model_points.each do |model_point|
            model_point.z = model_point.z - 5
        end
    end 
    def move_towards
        @model_points.each do |model_point|
            model_point.z = model_point.z + 5
        end
    end 

    def draw_quad(points, z_order_to_use = nil)
        if z_order_to_use.nil? 
            z_order_to_use = @render_z_order
        end
        if @draw_as_image 
            @img.draw_as_quad points[0].x, points[0].y, @color,
                              points[1].x, points[1].y, @color,
                              points[2].x, points[2].y, @color,
                              points[3].x, points[3].y, @color,
                              z_order_to_use
        else
            Gosu::draw_quad points[0].x, points[0].y, @color,
                            points[1].x, points[1].y, @color,
                            points[2].x, points[2].y, @color,
                            points[3].x, points[3].y, @color,
                            z_order_to_use
        end
    end 

    def draw_square(points, override_color = nil, z_order_to_use = nil)
        if z_order_to_use.nil? 
            z_order_to_use = @render_z_order
        end
        (0..3).each do |n|
            if n == 3
                draw_line(points, n, 0, override_color, z_order_to_use)
            else 
                draw_line(points, n, n + 1, override_color, z_order_to_use)
            end 
        end
    end
    
    def draw_line(points, index1, index2, override_color = nil, z_order_to_use = nil)
        point1 = points[index1]
        point2 = points[index2]
        color_to_use = override_color.nil? ? @color : override_color 
        z_order_to_use = z_order_to_use.nil? ? @render_z_order : z_order_to_use
        Gosu::draw_line point1.x, point1.y, color_to_use, point2.x, point2.y, color_to_use, z_order_to_use
    end

    def calc_points
        @render_points = [] 
        @model_points.each do |model_point|
            @render_points << calc_point(model_point,
                                         @scale,
                                         @angle_x, @angle_y, @angle_z,
                                         @move_x, @move_y)
        end 
    end 

    def rdia_sin(val)
        #$stats.increment("sin_#{val}")
        cached = $sin_cache[val]
        if cached.nil?
            cached = Math.sin(val)
            $sin_cache[val] = cached 
        end 
        cached
    end 

    def rdia_cos(val)
        #$stats.increment("cos_#{val}")
        cached = $cos_cache[val]
        if cached.nil?
            cached = Math.cos(val)
            $cos_cache[val] = cached 
        end 
        cached
    end

    def calc_point(model_point, scale, angle_x = 0, angle_y = 0, angle_z = 0, move_x = 0, move_y = 0)
        # XD = X(N)-PIVX
        # YD = Y(N)-PIVY
        # ZD = Z(N)-PIVZ
        xd = model_point.x - $center_x
        yd = model_point.y - $center_y
        zd = model_point.z - $center_z
        #if self.is_a? Cube 
        #    puts "#{xd}, #{yd}, #{zd}"
        #end

        # ZX = XD*Cos{ANGLEZ} - YD*Sin{ANGLEZ} - XD
        # ZY = XD*Sin{ANGLEZ} + YD*Cos{ANGLEZ} - YD
        z_cos = rdia_cos(angle_z)
        z_sin = rdia_sin(angle_z)
        y_cos = rdia_cos(angle_y)
        y_sin = rdia_sin(angle_y)
        x_cos = rdia_cos(angle_x)
        x_sin = rdia_sin(angle_x)

        zx = (xd * z_cos) - (yd * z_sin) - xd
        zy = (xd * z_sin) + (yd * z_cos) - yd

        # YX = [XD+ZX]*Cos{ANGLEY} - ZD*Sin{ANGLEY} - [XD+ZX]
        # YZ = [XD+ZX]*Sin{ANGLEY} + ZD*Cos{ANGLEY} - ZD
        yx = ((xd + zx) * y_cos) - (zd * y_sin) - (xd + zx)
        yz = ((xd + zx) * y_sin) + (zd * y_cos) - zd

        # XY = [YD+ZY]*Cos{ANGLEX} - [ZD+YZ]*Sin{ANGLEX} - [YD+ZY]
        # XZ = [YD+ZY]*Sin{ANGLEX} + [ZD+YZ]*Cos{ANGLEX} - [ZD+YZ]
        xy = ((yd + zy) * x_cos) - ((zd + yz) * x_sin) - (yd + zy)
        xz = ((yd + zy) * x_sin) + ((zd + yz) * x_cos) - (zd + yz)

        # XROTOFFSET = YX+ZX
        # YROTOFFSET = ZY+XY
        # ZROTOFFSET = XZ+YZ 
        x_rot_offset = yx + zx
        y_rot_offset = zy + xy 
        z_rot_offset = xz + yz

        #If MODE=0
        #    X = [ X(N) + XROTOFFSET + CAMX ] /SCALE +MOVEX
        #    Y = [ Y(N) + YROTOFFSET + CAMY ] /SCALE +MOVEY
        #Else
        #    Z = [ Z(N) + ZROTOFFSET + CAMZ ]
        #    X = [ X(N) + XROTOFFSET + CAMX ] /Z /SCALE +MOVEX
        #    Y = [ Y(N) + YROTOFFSET + CAMY ] /Z /SCALE +MOVEY
        #End If

        #if @mode == MODE_ISOMETRIC
        #    x = ((model_point.x + x_rot_offset + $camera_x) / scale) + move_x 
        #    y = ((model_point.y + y_rot_offset + $camera_y) / scale) + move_y
        #    z = model_point.z
        #else 
            z = model_point.z + z_rot_offset + $camera_z
            x = (((model_point.x + x_rot_offset + $camera_x) / z) / scale) + move_x 
            y = (((model_point.y + y_rot_offset + $camera_y) / z) / scale) + move_y
        #end 

        ThreeDPoint.new(x, y, z) 
    end
end 

class ThreeDLine < ThreeDObject
    def initialize(a, b, color = COLOR_AQUA)
        super(color)
        #puts "Creating line anchored at #{a.x}, #{a.z} to #{b.x}, #{b.z} "
        reset_angle_and_scale
        @model_points << a
        @model_points << b
    end

    def a 
        @model_points[0]
    end
    def b
        @model_points[1]
    end

    def render(z_order_to_use = nil)
        draw_line(@render_points, 0, 1, nil, z_order_to_use)
    end 

    def to_s 
        "Line: [#{a}] (#{@render_points[0]}) to [#{b}] (#{@render_points[1]})"
    end
end 

class FloorTile < ThreeDObject
    # The x, y, z coordinates are for the upper left corner
    def initialize(x, z, length = 100, color = COLOR_WHITE)
        super(color)
        @x = x 
        @y = 0 
        @z = z
        @length = length
        @draw_as_image = false
        reset
    end 

    def reset 
        reset_angle_and_scale
        @model_points << ThreeDPoint.new(@x,           @y,           @z)
        @model_points << ThreeDPoint.new(@x + @length, @y,           @z)
        @model_points << ThreeDPoint.new(@x + @length, @y,           @z + @length)
        @model_points << ThreeDPoint.new(@x,           @y,           @z + @length)
    end

    def render 
        draw_square([a, b, c, d])
    end 
end

class Wall < ThreeDObject
    # The x, y, z coordinates are for the upper left corner
    def initialize(x, z, width, length, img, is_external = false)
        super()
        @x = x 
        @y = 0
        @z = z
        @length = length
        @width = width
        @height = 100
        reset
        if img.nil? 
            # do nothing, this will get drawn as a solid color
        elsif img.is_a? String
            @img = Gosu::Image.new(img)
        elsif img.is_a? Gosu::Image
            @img = img
        else 
            raise "Invalid image parameter for wall constructor: #{img}"
        end
        
        @visible_side = QUAD_ALL
        @border_color = COLOR_WHITE

        @is_external = false 
        if is_external 
            @is_external = true
            @render_z_order = Z_ORDER_BORDER
        else 
            @render_z_order = Z_ORDER_GRAPHIC_ELEMENTS
        end
    end 

    def reset 
        reset_angle_and_scale
        #puts "Creating wall anchored at bottom left #{@x}, #{@z}"
        @model_points << ThreeDPoint.new(@x,          @y,           @z)
        @model_points << ThreeDPoint.new(@x + @width, @y,           @z)
        @model_points << ThreeDPoint.new(@x + @width, @y - @height, @z)
        @model_points << ThreeDPoint.new(@x,          @y - @height, @z)
        @model_points << ThreeDPoint.new(@x,          @y,           @z + @length)
        @model_points << ThreeDPoint.new(@x + @width, @y,           @z + @length)
        @model_points << ThreeDPoint.new(@x + @width, @y - @height, @z + @length)
        @model_points << ThreeDPoint.new(@x,          @y - @height, @z + @length)
    end

    def render 
        if not @visible 
            puts "We should not draw #{self}"
        end
        #return unless @visible
        draw_top 
        if @is_external
            # Right now, only N/S/E/W quads are used for external walls
            if @visible_side == QUAD_N 
                draw_back
            elsif @visible_side == QUAD_S 
                draw_front
            elsif @visible_side == QUAD_E
                draw_left_side
            elsif @visible_side == QUAD_W 
                draw_right_side
            end
            return 
        end

        if @visible_side == QUAD_N 
            draw_back(Z_ORDER_FOCAL_ELEMENTS)
        elsif @visible_side == QUAD_S 
            draw_front(Z_ORDER_FOCAL_ELEMENTS)
            draw_back
            draw_right_side 
            draw_left_side
        elsif @visible_side == QUAD_E
            draw_left_side(Z_ORDER_FOCAL_ELEMENTS)
            draw_back
            draw_right_side 
            draw_left_side
        elsif @visible_side == QUAD_W 
            draw_right_side(Z_ORDER_FOCAL_ELEMENTS) 
            draw_back
            draw_front 
            draw_left_side
        elsif @visible_side == QUAD_NE
            draw_back(Z_ORDER_FOCAL_ELEMENTS)
            draw_right_side(Z_ORDER_FOCAL_ELEMENTS) 
            draw_front 
            draw_left_side
        elsif @visible_side == QUAD_SE
            draw_front(Z_ORDER_FOCAL_ELEMENTS) 
            draw_right_side(Z_ORDER_FOCAL_ELEMENTS) 
            draw_back
            draw_left_side
        elsif @visible_side == QUAD_NW
            draw_back(Z_ORDER_FOCAL_ELEMENTS)
            draw_left_side(Z_ORDER_FOCAL_ELEMENTS) 
            draw_front 
            draw_right_side
        elsif @visible_side == QUAD_SW
            draw_front(Z_ORDER_FOCAL_ELEMENTS) 
            draw_left_side(Z_ORDER_FOCAL_ELEMENTS)
            draw_back
            draw_right_side
        elsif @visible_side == QUAD_ALL 
            draw_front 
            draw_back
            draw_right_side 
            draw_left_side
        else
            puts "[#{self.class.name}] Not drawing anything because visible side is #{@visible_side}."
        end
    end 

    def draw_front(z_order_to_use = nil) 
        draw_quad([a, b, c, d], z_order_to_use)
        draw_square([a, b, c, d], @border_color, z_order_to_use)
    end

    def draw_back(z_order_to_use = nil)
        draw_quad([e, f, g, h], z_order_to_use)    
        draw_square([e, f, g, h], @border_color, z_order_to_use)
    end

    def draw_right_side(z_order_to_use = nil)
        draw_quad([b, f, g, c], z_order_to_use)
        draw_square([b, f, g, c], @border_color, z_order_to_use)
    end 

    def draw_left_side(z_order_to_use = nil)
        draw_quad([a, e, h, d], z_order_to_use)
        draw_square([a, e, h, d], @border_color, z_order_to_use)
    end 

    def draw_top(z_order_to_use = nil)
        draw_quad([d, h, g, c], z_order_to_use)
        draw_square([d, h, g, c], @border_color, z_order_to_use)
    end 

    # Note in 2.5D this would never really get used
    def draw_bottom(z_order_to_use = nil) 
        draw_quad([a, e, f, b], z_order_to_use)  
        draw_square([a, e, f, b], @border_color, z_order_to_use)
    end
end

class Cube < Wall
    # The x, y, z coordinates are for the upper left corner
    def initialize(x, z, size, color = COLOR_AQUA)
        super(x, z, size, size, nil)
        @draw_as_image = false
        @color = color
    end 
end

class CubeRender < RdiaGame
    def initialize
        super(GAME_WIDTH, GAME_HEIGHT, "Cube Render", CubeRenderDisplay.new)
        register_hold_down_key(Gosu::KbQ)    
        register_hold_down_key(Gosu::KbW)    
        register_hold_down_key(Gosu::KbE)    
        register_hold_down_key(Gosu::KbR)
        register_hold_down_key(Gosu::KbT)
        register_hold_down_key(Gosu::KbY)
        register_hold_down_key(Gosu::KbU)
        register_hold_down_key(Gosu::KbI)
        register_hold_down_key(Gosu::KbO)

        register_hold_down_key(Gosu::KbA)
        register_hold_down_key(Gosu::KbS)
        register_hold_down_key(Gosu::KbD)
        register_hold_down_key(Gosu::KbF)
        register_hold_down_key(Gosu::KbG)
        register_hold_down_key(Gosu::KbH)
        register_hold_down_key(Gosu::KbJ)
        register_hold_down_key(Gosu::KbK)
        register_hold_down_key(Gosu::KbL)

        # scaling
        register_hold_down_key(Gosu::KbUp)
        register_hold_down_key(Gosu::KbDown)

        register_hold_down_key(Gosu::KbM)
        register_hold_down_key(Gosu::KbPeriod)

    end 
end

class CubeRenderDisplay < Widget
    include Gosu

    def initialize
        super(0, 0, GAME_WIDTH, GAME_HEIGHT)
        disable_border

        @image_external_wall = Gosu::Image.new("./media/tile5.png")
        @image_tile_18 = Gosu::Image.new("./media/tile18.png")

        # Draw offsets so the zero centered world is centered visually on the screen
        # This allows the initial center of the world to be 0, 0
        @offset_x = 600
        @offset_y = 300

        $stats = Stats.new("Perf")
        $cos_cache = {}
        $sin_cache = {}

        $center_x = 0
        $center_y = 0
        $center_z = -300   # orig -300
        $camera_x = 0
        $camera_y = 150
        $camera_z = 800   # orig 800

        @dir_x = 1     # initial direction vector
        @dir_y = 0   
        determine_directional_quadrant

        @pause = false
        @speed = 10
        @mode = MODE_ISOMETRIC
        @continuous_movement = true

        # Axis lines
        #@x_axis = ThreeDLine.new(ThreeDPoint.new(-1000, 0, 0), ThreeDPoint.new(1000, 0, 0))
        #@y_axis = ThreeDLine.new(ThreeDPoint.new(0, -AXIS_END, 0), ThreeDPoint.new(0, AXIS_END, 0))
        #@z_axis = ThreeDLine.new(ThreeDPoint.new(0, 0, -AXIS_END), ThreeDPoint.new(0, 0, AXIS_END))

        # Our objects
        @cube = Cube.new(-300, 300, 100, COLOR_LIME)
        @all_objects = [@cube]
        @other_objects = []

        @grid = GridDisplay.new(0, 0, 100, 21, 95, {ARG_X_OFFSET => 10, ARG_Y_OFFSET => 5})
        instantiate_elements(@grid, @all_objects, File.readlines("./data/editor_board.txt")) 
        puts "World Map"
        puts "---------"
        (0..94).each do |y|
            str = ""
            (0..20).each do |x|
                str = "#{str}#{@world_map[x][y]}"
            end 
            puts str
        end

        puts "Raycast Map"
        puts "-----------"
        (0..20).each do |y|
            str = ""
            (0..94).each do |x|
                str = "#{str}#{@raycast_map[x][y]}"
            end 
            puts str
        end

        @raycaster = RayCaster.new(@raycast_map, GAME_WIDTH, GAME_HEIGHT)

        # Near and far walls
        x = -1000
        while x < 550
            far_wall = Wall.new(x, 8900, 500, 100, @image_external_wall, true)
            far_wall.set_visible_side(QUAD_S)
            @all_objects << far_wall
            wall_behind_us = Wall.new(x, -500, 500, 100, @image_external_wall, true)
            wall_behind_us.set_visible_side(QUAD_N)
            @all_objects << wall_behind_us
            x = x + 500
        end

        # Side walls
        z = -500
        while z < 8910
            left_wall = Wall.new(-1000, z, 100, 500, "./media/tile5.png", true)
            left_wall.set_visible_side(QUAD_W)
            @all_objects << left_wall
            right_wall = Wall.new(1000, z, 100, 500, "./media/tile5.png", true)
            right_wall.set_visible_side(QUAD_E)
            @all_objects << right_wall
            z = z + 500
        end

        #@all_objects << Cube.new(300, 0, 300, 100, COLOR_GREEN)
        #@all_objects << Cube.new(300, 0, -300, 100, COLOR_BLUE)
        #@all_objects << Cube.new(-300, 0, -300, 100, COLOR_LIME)
        #@all_objects << Cube.new(50, 0, 0, 50, COLOR_AQUA)

        x = -1000
        while x < 950
            z = -500
            while z < 8890
                @all_objects << FloorTile.new(x, z, 200)
                z = z + 200
            end 
            x = x + 200
        end

        @text_1 = Text.new(10, 10, "")
        add_child(@text_1)
        @text_2 = Text.new(10, 40, camera_text)
        add_child(@text_2)
        @text_3 = Text.new(10, 70, angle_text)
        add_child(@text_3)
        @text_4 = Text.new(10, 100, dir_text)
        add_child(@text_4)
        @text_5 = Text.new(10, 130, objects_text)
        add_child(@text_5)
        @text_6 = Text.new(10, 160, center_text)
        add_child(@text_6)
        @text_7 = Text.new(10, 190, cube_text)
        add_child(@text_7)
    end 

    def add_to_maps(x, y, val)
        #puts "Array #{x},#{y} -> #{val}"
        @world_map[x][y] = val
        @raycast_map[y][x] = val
    end 

    def instantiate_elements(grid, all_objects, dsl)
        @world_map = Array.new(grid.grid_width) do |x|
            Array.new(grid.grid_height) do |y|
                0
            end 
        end 
        @raycast_map = Array.new(grid.grid_height) do |y|
            Array.new(grid.grid_width) do |x|
                0
            end 
        end 
        grid.clear_tiles
        grid_y = 89
        grid_x = -10
        dsl.each do |line|
            index = 0
            while index < line.size
                char = line[index..index+1].strip
                img = nil
                # set_tile is already using the grid offsets, but here
                # we are directly creating a world map array so we need
                # to use the same offsets
                # So the Grid should probably do this, not here, but oh well
                array_grid_x = grid_x + grid.grid_x_offset
                array_grid_y = grid_y + grid.grid_y_offset
                #if char == "B"
                #    img = Brick.new(@blue_brick)
                if char == "5"
                    # ignore 5 because we manually constructed the wall using bigger chunks
                    add_to_maps(array_grid_x, array_grid_y, 5)
                    #img = Wall.new(grid_x * 100, grid_y * 100)
                elsif char == "18"
                    add_to_maps(array_grid_x, array_grid_y, 18)
                    img = Wall.new(grid_x * 100, grid_y * 100, 100, 100, @image_tile_18)
                end
                
                if not img.nil?
                    puts "Set tile #{grid_x},#{grid_y}  =  #{char}"
                    grid.set_tile(grid_x, grid_y, img)
                    all_objects << img
                end

                #elsif char == "Y" or char == "18"
                #    img = Dot.new(@yellow_dot)
                #elsif char == "G" or char == "19"
                #    img = Dot.new(@green_dot)
                #elsif char == "F" or char == "66"
                #    img = OutOfBounds.new(@fire_transition_tile)
                #elsif char == "T"
                #    img = DiagonalWall.new(@red_wall_nw, QUAD_NW)
                #elsif char == "V"
                #    img = DiagonalWall.new(@red_wall_ne, QUAD_NE)
                #elsif char == "X"
                #    img = DiagonalWall.new(@red_wall_sw, QUAD_SW)
                #elsif char == "Z"
                #    img = DiagonalWall.new(@red_wall_se, QUAD_SE)
                #elsif char == "E" or char == "64"
                #    img = GoalArea.new(@goal_tile)
                #elsif char == "N"
                #    img = BackgroundArea.new(@tree_tile)
                #elsif char == "D"
                #    img = BackgroundArea.new(@torch_tile)
                #elsif char == "O"
                #    img = OneWayDoor.new(@one_way_tile, @red_wall)
                #    @one_way_doors << img
                #elsif char.match?(/[[:digit:]]/)
                #    tile_index = char.to_i
                #    img = BackgroundArea.new(@tileset[tile_index])


                grid_x = grid_x + 1
                index = index + 2
            end
            grid_x = -10
            grid_y = grid_y - 1
        end
    end 

    def modify(&block)
        @all_objects.each do |obj|
            yield obj
        end
    end

    # This uses algorithm described in https://www.skytopia.com/project/cube/cube.html
    def calc_points
        modify do |n|
            n.calc_points
        end

        # Show the origin (pivot) point as a cube
        #@center_cube = Cube.new($center_x, $center_z, 25, COLOR_LIGHT_BLUE)
        #@center_cube.angle_y = @all_objects[0].angle_y
        #@center_cube.calc_points

        # Darren Show the directional vector as a cube
        # initial direction vector    @dir_x = -1   @dir_y = 0   
        dir_scale = 100
        extended_dir_x = @dir_x * dir_scale  
        extended_dir_y = @dir_y * dir_scale  
        @dir_cube = Cube.new($center_x + extended_dir_y, $center_z + extended_dir_x, 25, COLOR_PEACH)
        @dir_cube.angle_y = @all_objects[0].angle_y
        @dir_cube.calc_points
    end 

    def render
        Gosu.translate(@offset_x, @offset_y) do
            #@center_cube.render
            #@dir_cube.render

            modify do |n|
                if n.is_behind_us 
                    # do not draw 
                    #puts "Not drawing #{n.class.name}"
                else
                    n.render
                end
            end

            # Other objects are essentially debug objects
            # we draw on top of everything else
            @other_objects.each do |oo|
                oo.render(20)
            end
        end 
    end

    def handle_update update_count, mouse_x, mouse_y
        return if @pause
        modify do |n|
            n.reset_visible_side
        end
        raycast_for_visibility

        calc_points
        @other_objects.each do |other_obj| 
            other_obj.calc_points 
        end

        @text_1.label = "Mouse: #{mouse_x}, #{mouse_y}"
        @text_2.label = camera_text
        @text_3.label = angle_text
        @text_4.label = dir_text
        number_of_invisible_objects = 0
        @all_objects.each do |obj| 
            if not obj.visible
                number_of_invisible_objects = number_of_invisible_objects + 1
            end 
        end
        @text_5.label = "#{objects_text}/#{number_of_invisible_objects}"
        @text_6.label = center_text
        @text_7.label = cube_text
    end

    def camera_text 
        "Camera: #{$camera_x.round(2)}, #{$camera_y.round(2)}, #{$camera_z.round(2)}" 
    end 
    def center_text 
        "Center: #{$center_x.round}, #{$center_y.round}, #{$center_z.round}" 
    end 
    def location_text 
        "Location: #{@cube.model_points[0].x.round}, #{@cube.model_points[0].y.round}, #{@cube.model_points[0].z.round}"
    end 
    def angle_text 
        "Angle: #{@cube.angle_x.round(2)}, #{@cube.angle_y.round(2)}, #{@cube.angle_z.round(2)}"
    end 
    def dir_text 
        "Direction: #{@dir_y.round(2)}, #{@dir_x.round(2)}    quad: #{@dir_quad}   grid: #{@grid.determine_grid_x($center_x)}, #{@grid.determine_grid_y($center_z)}"
    end 
    def objects_text 
        "Objects: #{@all_objects.size} "
    end
    def cube_text 
        #if @dir_cube
        #    return "Dir Cube: #{@dir_cube.model_points[0].x.round(2)}, #{@dir_cube.model_points[0].y.round(2)}, #{@dir_cube.model_points[0].z.round(2)}"
        #end
        "" 
    end

    def tile_at_proposed_grid(proposed_x, proposed_y) 
        tile_x = @grid.determine_grid_x(proposed_x) + @grid.grid_x_offset
        tile_y = @grid.determine_grid_y(proposed_y) + @grid.grid_y_offset
        #puts "tile_x/y:  #{tile_x}, #{tile_y}"
        @world_map[tile_x][tile_y]
    end 

    def determine_directional_quadrant
        if @all_objects.nil?
            @dir_quad = QUAD_N
            return
        end 
        if @all_objects.empty? 
            @dir_quad = QUAD_N 
            return
        end
        angle_y = @all_objects[0].angle_y
        angle_y = angle_y % DEG_360 
        if angle_y < DEG_22_5
            @dir_quad = QUAD_N
        elsif angle_y < DEG_67_5 
            @dir_quad = QUAD_NE
        elsif angle_y < DEG_112_5 
            @dir_quad = QUAD_E
        elsif angle_y < DEG_157_5 
            @dir_quad = QUAD_SE
        elsif angle_y < DEG_202_5 
            @dir_quad = QUAD_S
        elsif angle_y < DEG_247_5 
            @dir_quad = QUAD_SW
        elsif angle_y < DEG_292_5
            @dir_quad = QUAD_W 
        elsif angle_y < DEG_337_5 
            @dir_quad = QUAD_NW 
        else 
            @dir_quad = QUAD_N
        end
    end 

    def handle_key_held_down id, mouse_x, mouse_y
        if @continuous_movement
            handle_movement id, mouse_x, mouse_y 
        end 
    end

    def handle_key_press id, mouse_x, mouse_y
        handle_movement(id, mouse_x, mouse_y)
        if id == Gosu::KbSpace 
            @continuous_movement = !@continuous_movement
        elsif id == Gosu::KbP
            @cube.clear_points 
            @cube.reset
            modify do |n|
                n.angle_x = 0
                n.angle_y = 0
                n.angle_z = 0
            end
        elsif id == Gosu::KbUp
            @speed = @speed + 5
        elsif id == Gosu::KbDown
            @speed = @speed - 5
            if @speed < 5
                @speed = 5
            end
        elsif id == Gosu::KbC
            puts "------------"
            # Send a ray the direction we are looking (direction vector)
            # and see what it hits
            #t1 = Time.now
            #raycast_for_visibility
            #t2 = Time.now
            #delta = t2 - t1 # in seconds
            #puts "Raycast took #{delta} seconds"
            #(0..1279).each do |x|
            #    ray_data = raycast(x) 
            #    puts "[#{x}]  #{ray_data}"
            #end
            #puts " "
            
            #left_ray_data = raycast(0)
            #puts "left:  #{left_ray_data}"
            #left_point = Point.new(left_ray_data.map_y * 100, left_ray_data.map_x * 100)
            #middle_ray_data = raycast(640)
            #puts "mid:   #{middle_ray_data}"
            #right_ray_data = raycast(GAME_WIDTH)
            #puts "right: #{right_ray_data}"
            #right_point = Point.new(right_ray_data.map_y * 100, right_ray_data.map_x * 100)
            #vb = [camera_point, left_point, right_point]
            #vb = visibility_polygon
            
            #cx = $camera_x
            #cz = -$camera_z
            cx = $center_x
            cz = $center_z

            size_square = 1000
            dx, dz = perpendicular_direction_counter_clockwise(@dir_y, @dir_x)
            #side_left = ThreeDPoint.new(cx + (dx * size_square), 0, cz + (dz * size_square))
            side_left = Point.new(cx + (dx * size_square), cz + (dz * size_square))

            dx, dz = perpendicular_direction_clockwise(@dir_y, @dir_x)
            #side_right = ThreeDPoint.new(cx + (dx * size_square), 0, cz + (dz * size_square))
            side_right = Point.new(cx + (dx * size_square), cz + (dz * size_square))

            # TODO run this out to the edges of the world
            #      how to do best do that?
            #      line intersection seems non-trivial
            #forward_left = ThreeDPoint.new(side_left.x + (@dir_y * size_square), 0, side_left.z + (@dir_x * size_square))
            #forward_right = ThreeDPoint.new(side_right.x + (@dir_y * size_square), 0, side_right.z + (@dir_x * size_square))
            forward_left = Point.new(side_left.x + (@dir_y * size_square), side_left.y + (@dir_x * size_square))
            forward_right = Point.new(side_right.x + (@dir_y * size_square), side_right.y + (@dir_x * size_square))
            
            puts "Find intersecting lines with worlds edge"
            bottom_line = IntersectionLine.new(side_left, side_right)
            world_left_edge = IntersectionLine.new(Point.new(WORLD_X_START, WORLD_Z_START), side_right)

            l1 = IntersectionLine.new(Point.new(4, 0), Point.new(6, 10))
            l2 = IntersectionLine.new(Point.new(0, 3), Point.new(10, 7))
            puts "Line #{l1} intersects line #{l2} at #{l1.intersect(l2)}."


            vb = [side_left, forward_left, forward_right, side_right]

            #camera_point = Point.new($camera_x, -$camera_z)
            #100.times do 
            #    point = Point.new(cx, cz)
            #    puts point
            #    cx = cx + dx 
            #    cz = cz + dz
            #end
            puts "The visibility polygon is #{vb}"

            pip = PointInsidePolygon.new
            @all_objects.each do |an_obj|
                if an_obj.is_external or an_obj.is_a? FloorTile 
                    # skip 
                else 
                    point = Point.new(an_obj.model_points[0].x, an_obj.model_points[0].z)
                    
                    if pip.isInside(vb, 4, point)
                        # do nothing
                        puts "Inside #{an_obj}"
                        an_obj.color = COLOR_AQUA
                    else
                        puts "Setting #{an_obj} to invisible"
                        an_obj.color = COLOR_LIME
                        #@all_objects.delete(an_obj)
                    end
                end 
            end 

            @other_objects = []
            @other_objects << ThreeDLine.new(ThreeDPoint.new(vb[0].x, 0, vb[0].y), ThreeDPoint.new(vb[1].x, 0, vb[1].y), COLOR_RED)
            @other_objects << ThreeDLine.new(ThreeDPoint.new(vb[1].x, 0, vb[1].y), ThreeDPoint.new(vb[2].x, 0, vb[2].y), COLOR_RED)
            @other_objects << ThreeDLine.new(ThreeDPoint.new(vb[2].x, 0, vb[2].y), ThreeDPoint.new(vb[3].x, 0, vb[3].y), COLOR_RED)
            @other_objects << ThreeDLine.new(ThreeDPoint.new(vb[3].x, 0, vb[3].y), ThreeDPoint.new(vb[0].x, 0, vb[0].y), COLOR_RED)
        
        
        
        
        
        
        
        
        
        elsif id == Gosu::KbR
            modify do |n|
                if n.is_external 
                    # do nothing
                elsif n.is_a? Cube 
                    # do nothing
                elsif n.is_a? FloorTile 
                    # do nothing
                else
                    n.set_visible_side(QUAD_ALL)
                    n.color = COLOR_AQUA 
                end
            end
            #puts "------------"
            #puts "Lets raycast"
            #ray_line =  raycast(640) 
            #puts ray_line
            #slope = ray_line.slope 
            #puts slope
            #qfs = ray_line.quad_from_slope
            #puts "Quad: #{qfs}  #{str_qfs}"
        elsif id == Gosu::KbV 
            @pause = !@pause
        end
    end

    def visibility_polygon
        # TODO put the code back here
    end 

    def perpendicular_direction_clockwise(x, y)
        [y, -x]
    end

    def perpendicular_direction_counter_clockwise(x, y)
        [-y, x]
    end

    def display_quad(qfs)
        if qfs == QUAD_NW
            return "QUAD_NW"
        elsif qfs == QUAD_N
            return "QUAD_N"
        elsif qfs == QUAD_NE
            return "QUAD_NE"
        elsif qfs == QUAD_SW
            return "QUAD_SW"
        elsif qfs == QUAD_S
            return "QUAD_S"
        elsif qfs == QUAD_SE
            return "QUAD_SE"
        elsif qfs == QUAD_E
            return "QUAD_E"
        elsif qfs == QUAD_W
            return "QUAD_W"
        end
    end 

    def raycast_for_visibility
        (0..1279).each do |x|
        #(640..641).each do |x|
            ray_data = raycast(x) 
            if ray_data.at_ray != 0
                # Get the tile at this spot
                tile = @grid.get_tile(ray_data.map_y, ray_data.map_x)
                if tile
                    quad = ray_data.quad_from_slope
                    tile.set_visible_side(quad)

                    # This is for DEBUG
                    #if tile.is_a? Cube 
                        # do nothing
                    #else
                    #    tile.color = COLOR_RED
                    #end
                    #puts "#{ray_data} ->  #{tile.class.name} #{@grid.determine_grid_x(tile.model_points[0].x)}, #{@grid.determine_grid_y(tile.model_points[0].z)}  #{display_quad(quad)}"
                #else
                #    puts "#{ray_data} ->  #{tile}."
                end
            end
        end
    end

    def raycast(x, plane_x = 0, plane_y = 0.66) 
        #tile_x = @grid.determine_grid_x($camera_x)   # If you really see what is visible, use the camera
        #tile_y = @grid.determine_grid_y($camera_z)
        tile_x = @grid.determine_grid_x($center_x)
        tile_y = @grid.determine_grid_y($center_z)
        adj_tile_x = tile_x + @grid.grid_x_offset
        adj_tile_y = tile_y + @grid.grid_y_offset
        drawStart, drawEnd, mapX, mapY, side, orig_map_x, orig_map_y = @raycaster.ray(x, adj_tile_y, adj_tile_x, @dir_x, @dir_y, plane_x, plane_y)
        adj_map_x = mapX - @grid.grid_y_offset   # The raycast map is set the other way
        adj_map_y = mapY - @grid.grid_x_offset
        adj_orig_map_x = orig_map_x - @grid.grid_y_offset
        adj_orig_map_y = orig_map_y - @grid.grid_x_offset

        at_ray = @raycast_map[mapX][mapY]
        if at_ray == 5
            color_to_use = COLOR_AQUA
            if side == 1
                color_to_use = COLOR_BLUE
            end
        elsif at_ray == 18
            color_to_use = COLOR_LIME
            if side == 1
                color_to_use = COLOR_PEACH
            end
        end
        
        RayCastData.new(x, tile_x, tile_y, adj_map_x, adj_map_y, at_ray, side, drawStart, drawEnd, color_to_use, adj_orig_map_x, adj_orig_map_y)
    end

    def handle_movement id, mouse_x, mouse_y 
        #    @cube.move_left
        #    @cube.move_right
        #    @cube.move_up
        #    @cube.move_down
        #    @cube.move_towards
        #    @cube.move_away
        #elsif id == Gosu::KbU              # change camera elevation later, don't need it now
        #    $camera_y = $camera_y - @speed
        #elsif id == Gosu::KbO              # change camera elevation later, don't need it now
        #    $camera_y = $camera_y + @speed

        if id == Gosu::KbQ
            # Lateral movement
            $camera_x = $camera_x + @speed
            $center_x = $center_x - @speed
        elsif id == Gosu::KbE
            # Lateral movement
            $camera_x = $camera_x - @speed
            $center_x = $center_x + @speed
        elsif id == Gosu::KbW
            # Primary movement keys (WASD)
            movement_x = @dir_y * @speed
            movement_z = @dir_x * @speed

            proposed_x = $center_x + movement_x
            proposed_z = $center_z + movement_z
            proposed = tile_at_proposed_grid(proposed_x, proposed_z)
            if proposed == 0 
                $camera_x = $camera_x - movement_x
                $center_x = proposed_x

                $camera_z = $camera_z - movement_z
                $center_z = proposed_z
            #else 
            #    puts "Hit a wall: #{proposed}"
            end

        elsif id == Gosu::KbS
            movement_x = @dir_y * @speed
            movement_z = @dir_x * @speed

            proposed_x = $center_x - movement_x
            proposed_z = $center_z - movement_z
            proposed = tile_at_proposed_grid(proposed_x, proposed_z)
            if proposed == 0 
                $camera_x = $camera_x + movement_x
                $center_x = proposed_x

                $camera_z = $camera_z + movement_z
                $center_z = proposed_z
            #else 
            #    puts "Hit a wall: #{proposed}"
            end

        elsif id == Gosu::KbD
            modify do |n|
                n.angle_y = n.angle_y + 0.05
            end
            angle_y = @cube.angle_y  # just grab the value from one of the objects
            # Now calculate the new dir_x, dir_y
            @dir_x = Math.cos(angle_y)
            @dir_y = Math.sin(angle_y)
            determine_directional_quadrant
            #puts "Math.cos/sin(#{angle_y}) = #{@dir_y}, #{@dir_x}"
        elsif id == Gosu::KbA
            modify do |n|
                n.angle_y = n.angle_y - 0.05
            end
            angle_y = @cube.angle_y  # just grab the value from one of the objects
            # Now calculate the new dir_x, dir_y
            @dir_x = Math.cos(angle_y)
            @dir_y = Math.sin(angle_y)
            determine_directional_quadrant
            #puts "Math.cos/sin(#{angle_y}) = #{@dir_y}, #{@dir_x}"
        #
        # not really used
        #
        #elsif id == Gosu::KbF
        #    modify do |n|
        #        n.angle_x = n.angle_x - 0.05
        #    end
        #elsif id == Gosu::KbH
        #    modify do |n|
        #        n.angle_x = n.angle_x + 0.05
        #    end
        #elsif id == Gosu::KbR
        #    modify do |n|
        #        n.angle_y = n.angle_y - 0.05
        #    end
        #elsif id == Gosu::KbY
        #    modify do |n|
        #        n.angle_y = n.angle_y + 0.05
        #    end
        #elsif id == Gosu::KbT
        #    modify do |n|
        #        n.angle_z = n.angle_z - 0.05
        #    end
        #elsif id == Gosu::KbG
        #    modify do |n|
        #        n.angle_z = n.angle_z + 0.05
        #    end
        end
    end

    def handle_key_up id, mouse_x, mouse_y
        # nothing to do
    end

    def handle_mouse_down mouse_x, mouse_y
        @mouse_dragging = true
    end

    def handle_mouse_up mouse_x, mouse_y
        @mouse_dragging = false
    end
end

CubeRender.new.show
