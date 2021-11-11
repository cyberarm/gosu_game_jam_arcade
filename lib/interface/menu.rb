class GosuGameJamArcade
  class Interface
    class Menu < CyberarmEngine::GuiState
      FRAME_PADDING = 32
      FRAME_THICKNESS = 4

      def setup
        window.show_cursor = true

        @background_image = get_image("#{GosuGameJamArcade::GAME_ROOT_PATH}/media/background.png")
        @gosu_game_jam_logo = get_image("#{GosuGameJamArcade::GAME_ROOT_PATH}/media/gosu_game_jam_logo_large.png")

        @gosu_game_jam_logo_scale = 0.25

        @gosu_game_jam_logo_position = CyberarmEngine::Vector.new(
          window.width - (@gosu_game_jam_logo.width * @gosu_game_jam_logo_scale) / 2 - (FRAME_PADDING + FRAME_THICKNESS * 2),
          (FRAME_PADDING + FRAME_THICKNESS * 2) + (@gosu_game_jam_logo.height * @gosu_game_jam_logo_scale) / 2,
          10
        )

        flow(width: 1.0, height: 1.0, margin: FRAME_PADDING, padding: FRAME_THICKNESS) do
          button "Pet Peeve" do
            GosuGameJamArcade::Window.current_game = PetPeeve::GameWindow.new
            GosuGameJamArcade::Window.current_game.current_window = GosuGameJamArcade::Window.instance
          end

          button "Boxes !" do
            GosuGameJamArcade::Window.current_game = BoxesGame::Window.new
            GosuGameJamArcade::Window.current_game.current_window = GosuGameJamArcade::Window.instance
          end

          button "Relax", enabled: false
          button "Butterfly Surfer", enabled: false

          button "ChaosPenguin" do
            Omega.run(ChaosPenguinGame::Game, "#{ChaosPenguinGame::GAME_ROOT_PATH}/config.json")

            GosuGameJamArcade::Window.current_game = Omega.window
            GosuGameJamArcade::Window.current_game.current_window = GosuGameJamArcade::Window.instance
          end

          button "Scheduler" do
            GosuGameJamArcade::Window.current_game = SchedulerGame::Window.new(width: window.width, height: window.height)
            GosuGameJamArcade::Window.current_game.current_window = GosuGameJamArcade::Window.instance
          end

          button "Keep Calm & Balance", enabled: false
          button "Ruby Brickland", enabled: false
        end
      end

      def draw
        @background_image.draw(0, 0, 0)

        fill(0x44_222222)

        Gosu.draw_rect(
          FRAME_PADDING, FRAME_PADDING,
          window.width - FRAME_PADDING * 2, FRAME_THICKNESS,
          Gosu::Color::BLACK
        )
        Gosu.draw_rect(
          window.width - (FRAME_PADDING + FRAME_THICKNESS), FRAME_PADDING,
          FRAME_THICKNESS, window.height - FRAME_PADDING * 2,
          Gosu::Color::BLACK
        )
        Gosu.draw_rect(
          FRAME_PADDING, window.height - (FRAME_PADDING + FRAME_THICKNESS),
          window.width - FRAME_PADDING * 2, FRAME_THICKNESS,
          Gosu::Color::BLACK
        )
        Gosu.draw_rect(
          FRAME_PADDING, FRAME_PADDING,
          FRAME_THICKNESS, window.height - FRAME_PADDING * 2,
          Gosu::Color::BLACK
        )

        @gosu_game_jam_logo.draw_rot(
          @gosu_game_jam_logo_position.x,
          @gosu_game_jam_logo_position.y,
          @gosu_game_jam_logo_position.z,
          0,
          0.5,
          0.5,
          @gosu_game_jam_logo_scale,
          @gosu_game_jam_logo_scale
        )
        super
      end
    end
  end
end
