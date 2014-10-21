################################################################################
#
#   Xlib FFI interface to support TinyWM.rb
#
################################################################################

require 'rubygems'
require 'ffi'

# FFI binding for XLib (aka libX11.so)
module Xlib
  extend FFI::Library
  ffi_lib 'X11'

  attach_function :open_display, :XOpenDisplay, [:string], :pointer
  attach_function :root_window, :XDefaultRootWindow, [:pointer], :int
  attach_function :pending, :XPending, [:pointer], :int

  attach_function :grab_key, :XGrabKey, [
                  :pointer, # Display pointer
                  :uchar,   # key code type
                  :uint,    # modifiers
                  :ulong,   # Window
                  :int,     # owner events
                  :int,     # pointer mode
                  :int      # keyboard mode
  ], :int

  attach_function :grab_button, :XGrabButton, [
                  :pointer, # Display pointer
                  :uint,    # button
                  :uint,    # modifiers
                  :ulong,   # Window
                  :int,     # owner events
                  :uint,    # event mask
                  :int,     # pointer mode
                  :int,     # keyboard mode
                  :int,     # confine to
                  :int,     # cursor type
  ], :int

  module Events
    class Motion < FFI::Struct
      layout :c_type, :int,
             :serial, :ulong,
             :send_event, :int,
             :display, :pointer,
             :window, :ulong,
             :root, :ulong,
             :subwindow, :ulong,
             :time, :ulong,
             :x, :int,
             :y, :int,
             :x_root, :int,
             :y_root, :int,
             :state, :uint,
             :hint, :char,
             :same_screen, :int

      def to_s
        "<Xlib::Events::Motion:#{self.object_id}> #{self.members.map { |m| [m, self[m]]}}"
      end
    end

    # Return a distinct event class for the given event
    #
    # @param [Xlib::Event] event
    # @return [Object]
    def self.distinct_event_for(event)
      case event[:c_type]
        when 4
          return Motion.new(event.to_ptr)
        else
          return event
      end
    end
  end


  class Event < FFI::Union
    layout :c_type, :int,
           :xmotion, Events::Motion
  end

  attach_function :next, :XNextEvent, [
                    :pointer, # display pointer
                    Event, # event pointer
  ], :int

  module Mode
    GRAB_MODE_SYNC = 0
    GRAB_MODE_ASYNC = 1
  end

  module Keys
    extend FFI::Library
    ffi_lib 'X11'

    SHIFT = 2 ** 0
    LOCK = 2 ** 1
    CONTROL = 2 ** 2
    MOD_1 = 2 ** 3
    MOD_2 = 2 ** 4
    MOD_3 = 2 ** 5
    MOD_4 = 2 ** 6
    MOD_5 = 2 ** 7

    attach_function :symbol_to_code, :XKeysymToKeycode, [
                      :pointer, # Display pointer
                      :ulong    # key symbol
    ], :uchar # key code

    attach_function :string_to_symbol, :XStringToKeysym, [:string], :ulong
  end

  module Masks
    NO_EVENT = 0
    KEY_PRESS = 2 ** 0
    KEY_RELEASE = 2 ** 1
    BUTTON_PRESS = 2 ** 2
    BUTTON_RELEASE = 2 ** 3
    ENTER_WINDOW = 2 ** 4
    LEAVE_WINDOW = 2 ** 5
    POINTER_MOTION = 2 ** 6
    POINTER_MOTION_HINT = 2 ** 7
    BUTTON_1_MOTION = 2 ** 8
    BUTTON_2_MOTION = 2 ** 9
    BUTTON_3_MOTION = 2 ** 10
    BUTTON_4_MOTION = 2 ** 11
    BUTTON_5_MOTION = 2 ** 12
    BUTTON_MOTION = 2 ** 13
    KEYMAP_STATE = 2 ** 14
    EXPOSURE = 2 ** 15
    VISIBILITY_CHANGE = 2 ** 16
    STRUCTURE_NOTIFY = 2 ** 17
    RESIZE_REDIRECT = 2 ** 18
    SUBSTRUCTURE_NOTIFY = 2 ** 19
    SUBSTRUCTURE_REDIRECT = 2 ** 20
    FOCUS_CHANGE = 2 ** 21
    PROPERTY_CHANGE = 2 ** 22
    COLORMAP_CHANGE = 2 ** 23
    OWNER_GRAB_BUTTON = 2 ** 24
  end
end


