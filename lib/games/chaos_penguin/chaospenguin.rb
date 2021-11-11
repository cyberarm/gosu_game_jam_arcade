class ChaosPenguinGame
    class ChaosPenguin < Omega::SpriteSheet

        # Constants for platformer
        TEMPORARY_FAKE_GROUND = 360     # Detect at which Y position the ground is
        GRAVITY = 0.5                   # Gravity force apply to Chaos Penguin
        JUMP_FORCE = 18                 # Velocity Y applied when jumping
        MAX_VELOCITY_Y = 16             # Maximum Velocity Y allowed
        INCLINATION_ANGLE = 12          # Inclination of Chaos Penguin during movements
        SPEED = 2                       # Speed of the Chaos Penguin during movements

        # Constants for statistics
        HP_MAX = 100
        STAMINA_MAX = 100
        TIMER_HIT = 1
        TIMER_RECOVERY = 2              # Duration where Chaos Penguin cannot move after losing all its stamina
        TIMER_STAMINA = 0.1             # Obtain +1 Stamina every "TIMER_STAMINA" seconds

        # Stamina cost for actions
        COST_JUMP = 5
        COST_ATTACK = 10

        attr_accessor :velocity, :stamina
        attr_reader :can_move, :hp , :hitbox, :is_on_ground, :hitbox_hammer, :is_dead, :is_game_over

        def initialize(cam, map)
            super("#{ChaosPenguinGame::GAME_ROOT_PATH}/assets/ChaosPenguin_final.png", 256, 256);

            add_animation("IDLE", [0,1,2,1]);
            add_animation("WALK", [3,4,5,4]);
            add_animation("ATTACK", [6,7,8,8],0.3);
            add_animation("TIRED", [9,10,11]);
            play_animation("IDLE");

            @camera = cam;
            @map = map;
            @hitbox = Omega::Rectangle.new(0, 0, 1, 1);
            @hitbox_hammer = Omega::Rectangle.new(0, 0, 20, 20);
            @can_draw_hitbox = false;

            reset();
        end

        # Reset all data of this entity and put it back to its initial state
        def reset()
            @origin = Omega::Vector2.new(0.5,1);
            @scale = Omega::Vector2.new(1,1);

            # Define it's first position
            @position.x = @camera.position.x + (Omega.width/@camera.scale.x)*0.5 - (@width*0.5) + (@width*@origin.x) # Put the Chaos Penguin at the center of the scren
            @position.y = 10;
            @position.z = 1000; # Be sure that Chaos Penguin will be on the foreground above all other sprites.
            @velocity = Omega::Vector2.new(0,0);

            @timer_hit = 0;

            # Boolean to trace controls of the player actions
            @can_move = true;
            @is_dead = false;
            @is_game_over = false;
            @is_on_ground = false;
            @frame = 0;

            # Reset stats
            @hp = HP_MAX
            @stamina = STAMINA_MAX
            @timer_stamina = 0;
            @timer_recovery = TIMER_RECOVERY;
        end

        def update_hitbox()
            @hitbox.position.x = @position.x-(@width*@scale.x*@origin.x) + 0
            @hitbox.position.y = @position.y-(@height*@scale.y*@origin.y) + 0
            @hitbox.position.z = 100
            @hitbox.width = @width*@scale.x*0.4 - 0;
            @hitbox.height = @height*@scale.y - 0;

            @hitbox_hammer.position.x = @position.x-(@width*@scale.x*@origin.x) + 130
            @hitbox_hammer.position.y = @position.y-(@height*@scale.y*@origin.y) + 160
            @hitbox_hammer.position.z = 1000
            @hitbox_hammer.width = 80
            @hitbox_hammer.height = 80
        end

        # Update the velocity of the sprite and apply to its position
        def update_velocity()
            @position.x = @position.x + @velocity.x;
            @position.y = @position.y + @velocity.y;

            @velocity.y = @velocity.y.clamp( -MAX_VELOCITY_Y, MAX_VELOCITY_Y)
        end

        # Update the gravity (TODO : Enlever le fake ground par des collisions avec la map quand le moment sera venu)
        def update_gravity()
            @velocity.y += GRAVITY;
            check_collision()
        end

        def receive_hp(quantity)
            @hp += quantity;

            if (@hp >= HP_MAX) then
                @hp = HP_MAX;
            end
        end

        def receive_damage(quantity)
            return if (@timer_hit > 0);
            return if @hp <= 0;

            @hp -= quantity;
            @timer_hit = TIMER_HIT
            @camera.shake(20,-5,5);
            self.alpha = 100;
            @frame = 0;
            $sounds["hit"].play();

            if (@hp <= 0) then
                @is_dead = true;
                @hp = 0;
            end
        end

        def check_collision()
            @map.layers["solid"].each do |tile|
                if tile.collides?(@hitbox)
                    if tile.position.y + @map.tile_size < @hitbox.y + @hitbox.height && @hitbox.x + @hitbox.width >= tile.x && @hitbox.x < tile.x
                        @position.x = tile.position.x - @hitbox.width + self.width_scaled*@origin.x - 1
                        update_hitbox()
                    elsif tile.position.y + @map.tile_size < @hitbox.y + @hitbox.height && @hitbox.x <= tile.x + @map.tile_size
                        @position.x = tile.position.x + @map.tile_size + self.width_scaled*@origin.x + 1
                        update_hitbox()
                    elsif @hitbox.y + @hitbox.height >= tile.y && @velocity.y >= 0
                        @velocity.y = 0;
                        @position.y = tile.position.y - self.height_scaled + (@height*origin.y);

                        # First time hit the ground :
                        if !@is_on_ground then
                            $sounds["land"].play();
                            @camera.shake(20,-2,2);
                            @is_on_ground = true;
                        end
                        update_hitbox()
                    end
                end
            end
        end

        def lose_stamina(quantity)
            @stamina -= quantity

            if (@stamina <= 0) then
                @stamina = 0;
                play_animation("TIRED");
            end
        end


        def play_walk_sound()
            @sound_walk = $sounds["walk"].play() if not @sound_walk
            if !@sound_walk.playing? and @is_on_ground then
                @sound_walk = $sounds["walk"].play()
            end
        end

        # Make the sprite move left/right and jump
        def move()

            # Movement Right and left
            if Omega::pressed(Gosu::KB_RIGHT) or Omega::pressed(Gosu::GP_0_RIGHT) then
                @velocity.x = SPEED;
                play_animation("WALK") if (@current_animation != "WALK");
                #@flip.x = false;

                play_walk_sound();

            elsif Omega::pressed(Gosu::KB_LEFT) or Omega::pressed(Gosu::GP_0_LEFT) then
                @velocity.x = -SPEED;
                #@flip.x = true;
                play_animation("WALK") if (@current_animation != "WALK");

                play_walk_sound();

            else
                play_animation("IDLE") if (@current_animation != "IDLE")
            end

            # Jump
            if @stamina >= COST_JUMP and @is_on_ground and (Omega::just_pressed(Gosu::KB_SPACE) or Omega::just_pressed(Gosu::GP_0_BUTTON_0)) then
                $sounds["jump"].play();
                @velocity.y = -JUMP_FORCE;
                @position.y -= 1
                @is_on_ground = false
                lose_stamina(COST_JUMP);
            end

        end

        def attack()
            if @stamina >= COST_ATTACK and (Omega::just_pressed(Gosu::KB_X) or Omega::just_pressed(Gosu::GP_0_BUTTON_2)) then
                $sounds["attack"].play();
                play_animation("ATTACK", false);
                lose_stamina(COST_ATTACK);
            end

        end

        def update_stamina()

            if (@stamina <= 0) then
                @timer_recovery -= 0.01
                @can_move = false;

                if (@timer_recovery < 0) then
                    @timer_recovery = TIMER_RECOVERY;
                    @stamina = STAMINA_MAX;
                    @can_move = true;
                end

            elsif (@stamina > 0 and @stamina < 100) then
                @timer_stamina -= 0.01

                if (@timer_stamina < 0) then
                    @stamina += 1
                    @stamina = 100 if (@stamina >= 100)

                    @timer_stamina = TIMER_STAMINA

                end
            end
        end

        def update()
            super();

            if (@position.y >= @map.height) then
                @is_game_over = true;
            end

            update_velocity();

            if (@is_dead) then
                if (@origin.y != 0.5) then
                    $sounds["death"].play();
                    @origin = Omega::Vector2.new(0.5,0.5);
                end

                self.alpha = 255
                @color = Omega::Color.copy(Gosu::Color::BLACK);

                @velocity.x = -1;
                @velocity.y = -2;
                @angle -= 12;
                @scale.x -= 0.01
                @scale.y -= 0.01

                if (@scale.x <= 0) then
                    @scale = Omega::Vector2.new(0,0);
                    @is_game_over = true;
                end

                return
            end

            # Chaos penguin cannot go behind the camera
            if (@position.x <= -@camera.position.x + @hitbox.width) then
                @position.x = (-@camera.position.x + @hitbox.width);
            end

            update_gravity() # if !@is_on_ground

            @velocity.x = 0;
            if (@can_move && @current_animation != "ATTACK") then
                move()
                attack()
            end

            # Return back to the default animation when attack is finished
            if (finished?() and @current_animation == "ATTACK") then
                play_animation("IDLE");
            end

            update_hitbox();

            if (@timer_hit >= 0) then
                @timer_hit -= 0.01;

                @frame += 1

                self.alpha = (@frame%20 == 0) ? 200 : 120

                if (@timer_hit <= 0) then
                    @timer_hit = 0;
                    self.alpha = 255;
                end

            end

            update_stamina();

        end

        def draw()
            super();

            @hitbox.draw if (@can_draw_hitbox)
            @hitbox_hammer.draw if (@can_draw_hitbox);
        end

    end
end