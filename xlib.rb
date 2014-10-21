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

  attach_function :raise_window, :XRaiseWindow, [:pointer, :ulong], :int

  attach_function :grab_pointer, :XGrabPointer, [
                    :pointer, # display
                    :ulong, # window
                    :int, # owner events
                    :uint, # event mask
                    :int, # pointer mode
                    :int, # keyboard mode
                    :ulong, # window to confine to
                    :ulong, # cursor type
                    :ulong, # time
  ], :int

  attach_function :ungrab_pointer, :XUngrabPointer, [:pointer, :ulong], :int


  module Events
    class BaseEvent < FFI::Struct
      def to_s
        "<#{self.class.name}:#{self.object_id}> #{self.members.map { |m| [m, self[m]]}}"
      end
    end

    class KeyPress < BaseEvent
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
             :keycode, :uint,
             :same_screen, :int
    end
    KeyRelease = KeyPress.dup

    class ButtonPress < BaseEvent
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
             :button, :uint,
             :hint, :char,
             :same_screen, :int
    end
    ButtonRelease = ButtonPress.dup

    # MotionNotify has the same structure as the botton press events
    MotionNotify = ButtonPress.dup

    KEY_PRESS = 2
    KEY_RELEASE = 3
    BUTTON_PRESS = 4
    BUTTON_RELEASE = 5
    MOTION_NOTIFY = 6
    ENTER_NOTIFY = 7
    LEAVE_NOTIFY = 8
    FOCUS_IN = 9
    FOCUS_OUT = 10
    KEYMAP_NOTIFY = 11
    EXPOSE = 12
    GRAPHICS_EXPOSE = 13
    NO_EXPOSE = 14
    VISIBILITY_NOTIFY = 15
    CREATE_NOTIFY = 16
    DESTROY_NOTIFY = 17
    UNMAP_NOTIFY = 18
    MAP_NOTIFY = 19
    MAP_REQUEST = 20
    REPARENT_NOTIFY = 21
    CONFIGURE_NOTIFY = 22
    CONFIGURE_REQUEST = 23
    GRAVITY_NOTIFY = 24
    RESIZE_REQUEST = 25
    CIRCULATE_NOTIFY = 26
    CIRCULATE_REQUEST = 27
    PROPERTY_NOTIFY = 28
    SELECTION_CLEAR = 29
    SELECTION_REQUEST = 30
    SELECTION_NOTIFY = 31
    COLORMAP_NOTIFY = 32
    CLIENT_MESSAGE = 33
    MAPPING_NOTIFY = 34
    GENERIC_EVENT = 35
    LAST_EVENT = 36

    # Return a distinct event class for the given event
    #
    # @param [Xlib::Event] event
    # @return [Object]
    def self.distinct_event_for(event)
      case event[:c_type]
      when KEY_PRESS
        return KeyPress.new(event.to_ptr)
      when KEY_RELEASE
        return KeyRelease.new(event.to_ptr)
      when BUTTON_PRESS
        return ButtonPress.new(event.to_ptr)
      when BUTTON_RELEASE
        return ButtonRelease.new(event.to_ptr)
      when MOTION_NOTIFY
        return MotionNotify.new(event.to_ptr)
      else
        return event
      end
    end
  end


  class Event < FFI::Union
    layout :c_type, :int,
           :xkeypress, Events::KeyPress,
           :xbutton, Events::ButtonPress
  end

  class WindowAttributes < FFI::Struct
    layout :x, :int,
           :y, :int,
           :width, :int,
           :height, :int,
           :border_width, :int,
           :depth, :int,
           :visual, :ulong,
           :root_window, :ulong,
           :class, :int,
           :bit_gravity, :int,
           :lin_gravity, :int,
           :backing_store, :int,
           :backing_planes, :ulong,
           :backing_pixel, :ulong,
           :save_under, :int,
           :colormap, :ulong,
           :map_installed, :int,
           :map_state, :int,
           :event_masks, :long,
           :your_event_mask, :long,
           :dont_propogate_mask, :long,
           :override_redirect, :int,
           :screen, :pointer
  end

  attach_function :next, :XNextEvent, [
                    :pointer, # display pointer
                    Event, # event pointer
  ], :int

  attach_function :window_attributes, :XGetWindowAttributes, [
                    :pointer, # display
                    :ulong, # window
                    WindowAttributes, # attributes pointer
  ], :int

  attach_function :move_or_resize_window, :XMoveResizeWindow, [
                    :pointer, # display,
                    :ulong, # window
                    :int, # x
                    :int, # y,
                    :uint, # width,
                    :uint, # height
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


