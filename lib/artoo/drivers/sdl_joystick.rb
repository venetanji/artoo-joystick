require 'artoo/drivers/driver'

module Artoo
  module Drivers
    # The sdl-joystick driver behaviors
    class SdlJoystick < Driver
      attr_reader :button_values

      # Start driver and any required connections
      def start_driver
        @button_values = {}

        begin
          every(interval) do
            handle_message_events
          end

          super
        rescue Exception => e
          Logger.error "Error starting SdlJoystick driver!"
          Logger.error e.message
          Logger.error e.backtrace.inspect
        end
      end

      def handle_message_events
        connection.poll
        handle_joystick
        handle_trackball
        handle_buttons
      end

      def handle_joystick
        x = connection.axis(0)
        y = connection.axis(1)
        
        publish(event_topic_name("update"), "joystick", {:x => x, :y => y})
        publish(event_topic_name("joystick"), {:x => x, :y => y})
      end

      def handle_trackball
        if connection.num_balls == 1
          x, y = connection.ball(0)
        
          publish(event_topic_name("update"), "trackball", {:x => x, :y => y})
          publish(event_topic_name("trackball"), {:x => x, :y => y})
        end
      end

      def handle_buttons
        connection.num_buttons.times {|b|
          currently_pressed = connection.button(b)
          if button_values[b] != currently_pressed
            button_values[b] = currently_pressed
            if currently_pressed
              publish(event_topic_name("update"), "button", b)
              publish(event_topic_name("button"), b)
              publish(event_topic_name("button_#{b}"))
            end
          end
        }
      end
    end
  end
end
