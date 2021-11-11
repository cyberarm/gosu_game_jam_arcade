class SoldierPenguin < Monster

    TIMER_WALK = 1
    SPEED = 1

    def initialize(chaos_penguin, camera)
        super(chaos_penguin, camera, "#{ChaosPenguinGame::GAME_ROOT_PATH}/assets/enemy1.png",64,128);

        add_animation("WALK", [0,1,2,3]);
        add_animation("DIE", [0]);
        play_animation("WALK");

        @position.x = Omega.width*0.4;
        @position.y = 232 + (@origin.y * @height);
        @timer_walk = TIMER_WALK;

        @hp = 3;
        @damage = 10

        @velocity.x = -SPEED;
        @can_draw_hitbox = false;
    end

    def update()
        super()

        @timer_walk -= 0.01;

        if (@timer_walk < 0) then
            @velocity.x = -@velocity.x;
            @timer_walk = TIMER_WALK;
        end

        @flip.x = (@velocity.x < 0) ? true : false;

        if (@is_dead) then
            play_animation("DIE");
        end

    end

    def draw()
        super()

    end

end