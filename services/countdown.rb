require 'glimmer-dsl-libui'


module Service
  # class for countdown timer used for auto-refreshing the merge request list and issues list
  class Countdown

    attr_accessor :countdown_seconds, :countdown_timer_started_at, :countdown_timer_paused_at,
                  :countdown_timer_resumed_at, :countdown_timer_stopped_at, :timer_running

    def initialize(countdown_seconds: 60, on_timer_complete: nil, on_tick: nil)
      @initial_countdown_seconds = countdown_seconds
      @countdown_seconds = countdown_seconds
      @countdown_timer_started_at = nil
      @countdown_timer_paused_at = nil
      @countdown_timer_resumed_at = nil
      @countdown_timer_stopped_at = nil
      @timer_running = false
      @on_timer_complete = on_timer_complete
      @on_tick = on_tick
      @timer_has_been_started = false
    end

    def start
      if @timer_has_been_started
        resume
        return
      end

      @timer_running = true
      @countdown_timer_started_at = Time.now
      @the_main_timer = Glimmer::LibUI::timer(1, repeat: @timer_running) do
        false unless @timer_running

        @countdown_seconds -= 1
        @on_tick&.call(@countdown_seconds.dup)
        if @countdown_seconds <= 0
          stop
          @on_timer_complete&.call
        end
        @timer_running
      end
    end

    def pause
      @timer_running = false
      @countdown_timer_paused_at = Time.now
    end

    def resume
      @timer_running = true
      @countdown_timer_resumed_at = Time.now
      # Glimmer::LibUI::timer(1, repeat: @timer_running) do
      #  @countdown_seconds -= 1
      #  stop if @countdown_seconds <= 0
      # end
    end

    def stop
      @timer_running = false
      @countdown_timer_stopped_at = Time.now
    end

    def reset
      @countdown_seconds = @initial_countdown_seconds
    end

    def change_countdown_seconds(countdown_seconds)
      stop
      @initial_countdown_seconds = countdown_seconds
      @countdown_seconds = countdown_seconds
    end

    def time_elapsed
      if @countdown_timer_started_at.present?
        Time.now - @countdown_timer_started_at
      else
        0
      end
    end

    def time_paused
      if @countdown_timer_paused_at.present?
        Time.now - @countdown_timer_paused_at
      else
        0
      end
    end

    def time_resumed
      if @countdown_timer_resumed_at.present?
        Time.now - @countdown_timer_resumed_at
      else
        0
      end
    end

    def time_stopped
      if @countdown_timer_stopped_at.present?
        Time.now - @countdown_timer_stopped_at
      else
        0
      end
    end

    def time_remaining
      @countdown_seconds
    end

    def time_elapsed_formatted
      format_seconds(time_elapsed)
    end

    def time_paused_formatted
      format_seconds(time_paused)
    end

    def time_resumed_formatted
      format_seconds(time_resumed)
    end

    def time_stopped_formatted
      format_seconds(time_stopped)
    end

    def time_remaining_formatted
      format_seconds(time_remaining)
    end

    def format_seconds(seconds)
      Time.at(seconds).utc.strftime("%H:%M:%S")
    end

    def time_elapsed_percentage
      (time_elapsed.to_f / (time_elapsed + time_remaining)) * 100
    end

    def time_paused_percentage
      (time_paused.to_f / (time_paused + time_remaining)) * 100
    end

    def time_resumed_percentage
      (time_resumed.to_f / (time_resumed + time_remaining)) * 100
    end

    def time_stopped_percentage
      (time_stopped.to_f / (time_stopped + time_remaining)) * 100
    end

    def time_remaining_percentage
      (time_remaining.to_f / (time_remaining + time_elapsed)) * 100
    end

    def time_elapsed_color
      time_elapsed_percentage > 50 ? :red : :green
    end

    def time_paused_color
      time_paused_percentage > 50 ? :red : :green
    end

    def time_resumed_color
      time_resumed_percentage > 50 ? :red : :green
    end

    def time_stopped_color
      time_stopped_percentage > 50 ? :red : :green
    end

    def time_remaining_color
      time_remaining_percentage > 50 ? :red : :green
    end
  end
end
