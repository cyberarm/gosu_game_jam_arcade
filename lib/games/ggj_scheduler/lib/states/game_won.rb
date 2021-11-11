class SchedulerGame
  class States
    class GameWon < CyberarmEngine::GuiState
      def setup
        window.show_cursor = true

        @game_time = @options[:game_time]
        @map = @options[:map]

        Gosu::Song.current_song&.stop

        background 0xff_222222

        flow(width: 1.0, height: 1.0) do
          stack width: 0.3, height: 1.0, padding: 24 do
            banner "SCHEDULER", width: 1.0, text_align: :center

            button "PLAY AGAIN", width: 1.0 do
              push_state(States::Game)
            end

            button "QUIT", width: 1.0 do
              window.close
            end
          end

          stack width: 0.7, height: 1.0, padding: 24 do
            background 0xff_004000

            banner "Success!", width: 1.0
            title "Took: #{format_clock}", width: 1.0
            title "Cleared: All #{@map.travellers.size} Travellers", width: 1.0
          end
        end
      end

      def format_clock
        minutes = (@game_time / 60.0) % 60.0
        seconds = @game_time % 60.0

        "#{minutes.floor.to_s.rjust(2, '0')}:#{seconds.floor.to_s.rjust(2, '0')}"
      end
    end
  end
end
