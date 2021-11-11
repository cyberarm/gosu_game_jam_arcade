class SchedulerGame
  class Node
    attr_reader :position, :type, :color, :data

    def initialize(position:, type:, color:)
      @position = position
      @type = type
      @color = color

      @data = {}
    end
  end
end
