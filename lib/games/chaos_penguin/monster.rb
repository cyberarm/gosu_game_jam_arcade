class Monster < Omega::SpriteSheet

    DEATH_DIRECTION_FOREGROUND = "foreground"
    DEATH_DIRECTION_BACKGROUND = "background"

    DEATH_SPEED_SCALE = 0.02
    DEATH_MAX_SCALE = 1.8
    DEATH_ANGLE = 20

    MAX_VELOCITY_Y = 8

    TIMER_HIT = 0.3;

    attr_reader :hp, :is_dead, :hitbox, :is_taking_damage
    attr_accessor :can_draw_hitbox, :damage, :velocity

    def initialize(chaos_penguin, camera, asset, width, height)
        super(asset, width, height);

        @chaos_penguin = chaos_penguin;
        @camera = camera;
        @position.z = 1000;
        @origin = Omega::Vector2.new(0.5,0.5);
        @hitbox = Omega::Rectangle.new(0,0,1,1);

        @sprite_window = Omega::Sprite.new("#{ChaosPenguinGame::GAME_ROOT_PATH}/assets/breakingWindow.png");
        @sprite_window.origin = Omega::Vector2.new(0.5,0.5);
        @sprite_window.scale = Omega::Vector2.new(3,3);

        @is_taking_damage = false;
        @damage = 10

        @can_shake = true;

        reset();
    end

    def reset()
        @velocity = Omega::Vector2.new(0,0);

        @hp_max = 1
        @hp = @hp_max

        @is_dead = false;
        @first_frame_die = false;
        @can_disappear = false;

        @death_direction = "foreground" # "foreground" / "background"
        @timer_hit = 0;

        @can_draw_hitbox = false;
    end

    def update_hitbox()
        @hitbox.position.x = @position.x-(@width*@scale.x*@origin.x) + 0
        @hitbox.position.y = @position.y-(@height*@scale.y*@origin.y) +0
        @hitbox.width = @width*@scale.x - 0;
        @hitbox.height = @height*@scale.y - 0;
    end

    def receive_damage(quantity)

        return if @timer_hit > 0
        return if @hp <= 0

        @hp -= quantity;
        @timer_hit = TIMER_HIT;
        @color = Omega::Color.copy(Gosu::Color::RED);
        @scale.x = @scale.y = 2.4
        @is_taking_damage = true;

        if (@hp <= 0) then
            @is_dead = true;
            @hp = 0;
            @chaos_penguin.receive_hp(20);
            @is_taking_damage = false;
        end

    end

    # Select if the death animation will go in the foreground or in the background
    def choose_death_direction()
        return (rand(0..1) == 0) ? DEATH_DIRECTION_FOREGROUND : DEATH_DIRECTION_BACKGROUND;
    end

    def gestion_collision()
        return if (@is_dead)

        # Collision while jumping
        if (!@chaos_penguin.is_on_ground and @chaos_penguin.velocity.y > 0 and @chaos_penguin.hitbox.collides?(@hitbox)) then
            receive_damage(1);
            return
        end

        # Collision while attacking
        if (@chaos_penguin.current_animation == "ATTACK" and @chaos_penguin.current_frame >= 1 and @chaos_penguin.hitbox_hammer.collides?(@hitbox)) then
            receive_damage(1);
            return
        end

        if (@chaos_penguin.hitbox.collides?(@hitbox)) then
            @chaos_penguin.receive_damage(@damage);
        end
    end

    def gestion_death()
        if (@is_dead) then
            @velocity.x = @velocity.y = 0;

            # Do stuff during the first frame the monster dies :
            if (!@first_frame_die) then

                @death_direction = choose_death_direction();
                $sounds["hit"].play();


                @origin = Omega::Vector2.new(0.5,0.5);

                @first_frame_die = true;
            end

            # Depending on the direction of its death, the action will not be the same :
            if (@death_direction == "foreground") then
                if (@scale.x >= DEATH_MAX_SCALE) then
                    @scale = Omega::Vector2.new(DEATH_MAX_SCALE,DEATH_MAX_SCALE);
                    @position.z = 10000;

                    @camera.shake(20,-6,6) if (@can_shake)

                    @can_shake = false;

                    @can_disappear = true;

                else

                    @angle += DEATH_ANGLE;
                    @color = Omega::Color.copy(Gosu::Color::BLACK);
                    @scale.x += DEATH_SPEED_SCALE
                    @scale.y += DEATH_SPEED_SCALE
                end

            else
                if (@scale.x <= 0) then
                    @scale = Omega::Vector2.new(0,0);
                    @can_disappear = true;
                    @sprite_window.position = @position;


                else
                    @angle -= DEATH_ANGLE;
                    @color = Omega::Color.copy(Gosu::Color::BLACK);
                    @scale.x -= DEATH_SPEED_SCALE
                    @scale.y -= DEATH_SPEED_SCALE
                end

            end

        end

        if (@can_disappear) then
            self.alpha -= 0.5;
            @sprite_window.position = @position;
            @sprite_window.alpha = self.alpha;

            @sprite_window.alpha = 0 if (@death_direction == DEATH_DIRECTION_BACKGROUND)

            if (self.alpha <= 0) then
                self.alpha = 0;
            end
        end
    end

    def update_velocity()
        @position.x = @position.x + @velocity.x;
        @position.y = @position.y + @velocity.y;

        @velocity.y = @velocity.y.clamp( -MAX_VELOCITY_Y, MAX_VELOCITY_Y)
    end

    def update()
        super()

        update_velocity();

        update_hitbox();

        gestion_collision();

        gestion_death();

        @sprite_window.update();

        if (@timer_hit > 0) then
            @timer_hit -= 0.01;

            @scale.x = @scale.y -= 0.1

            if (@scale.x <= 1) then
                @scale.x = @scale.y = 1;
            end

            if (@timer_hit <= 0) then
                @scale = Omega::Vector2.new(1,1);
                @is_taking_damage = false;
                @color = Omega::Color.copy(Gosu::Color::WHITE);
            end
        end

    end

    def draw()
        super()

        if (@can_disappear and @scale.x >= DEATH_MAX_SCALE) then
            @sprite_window.draw();
        end

        @hitbox.draw if (@can_draw_hitbox)

    end



end