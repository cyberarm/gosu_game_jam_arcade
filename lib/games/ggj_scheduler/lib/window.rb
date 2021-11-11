class SchedulerGame
  class Window < CyberarmEngine::Window
    def setup
      push_state(CyberarmEngine::IntroState, forward: SchedulerGame::States::MainMenu)
      # push_state(SchedulerGame::States::MainMenu)
      # push_state(SchedulerGame::States::GameLost)
      # push_state(SchedulerGame::States::GameWon)
      # push_state(SchedulerGame::States::Game)

      self.caption = "Scheduler"
    end

    def button_down(id)
      super

      return if @states.first.is_a?(CyberarmEngine::IntroState) || @states.first.is_a?(SchedulerGame::States::MainMenu)

      close if id == Gosu::KB_ESCAPE
    end
  end
end
