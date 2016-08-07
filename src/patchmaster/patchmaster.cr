require "./web/web"

# Global behavior: master list of songs, list of song lists, stuff like
# that.
#
# Typical use:
#
#   PatchMaster.instance.load("my_pm_dsl_file")
#   PatchMaster.instance.start
#   # ...when you're done
#   PatchMaster.instance.stop
class PatchMaster

  @@patchmaster : PatchMaster = PatchMaster.new

  @gui : (Main | IRB | Web | Nil)
  @all_songs : SortedSongList
  @cursor : Cursor = Cursor.new(@@patchmaster)

  property all_songs, use_midi

  def self.instance
    @@patchmaster
  end

  def initialize
    @inputs = [] of InputInstrument
    @outputs = [] of OutputInstrument
    @all_songs = SortedSongList.new("All Songs")
    @song_lists = [] of SongList
    @messages = {} of String => Array(Int8)
    @message_bindings = {} of Char => String
    @code_bindings = {} of Char => CodeKey
    @use_midi = true
    @gui = nil

    @running = false
  end

  def init
    @cursor = Cursor.new(self)
  end

  def no_gui!
    @no_gui = true
  end

  # Loads +file+. Does its best to restore the current song list, song, and
  # patch after loading.
  def load(file)
    restart = running?
    stop

    @cursor.mark
    init_data
    DSL.new.load(file)
    @loaded_file = file
    @cursor.restore

    if restart
      start(false)
    elsif @cursor.patch
      @cursor.patch.start
    end
  rescue ex
    raise("error loading #{file}: #{ex}\n" + caller.join("\n"))
  end

  def save(file)
    DSL.new.save(file)
    @loaded_file = file
  rescue ex
    raise("error saving #{file}: #{ex}" + caller.join("\n"))
  end

  def bind_message(name, key)
    @message_bindings[key] = name
  end

  def bind_code(code_key)
    @code_bindings[code_key.key] = code_key
  end

  # Initializes the cursor and all data.
  def init_data
    @cursor.clear
    @inputs = [] of Instrument::InputInstrument
    @outputs = [] of Instrument::OutputInstrument
    @song_lists = [] of SongList
    @all_songs = SortedSongList.new("All Songs")
    @song_lists << @all_songs
    @messages = {} of Name => typeof([] of Int8)
  end

  # If +init_cursor+ is +true+ (the default), initializes current song list,
  # song, and patch.
  def start(init_cursor = true)
    @cursor.init if init_cursor
    @cursor.patch.start if @cursor.patch
    @running = true
    @inputs.map(&:start)
  end

  # Stop everything, including input instruments' MIDIEye listener threads.
  def stop
    @cursor.patch.stop
    @inputs.map(&:stop)
    @running = false
  end

  # Run PatchMaster without the GUI. Don't use this when using Main. If
  # there is a GUI then forward this request to it. Otherwise, call #start,
  # wait for inputs' MIDIEye listener threads to finish, then call #stop.
  # Note that normally nothing stops those threads, so this is used as a way
  # to make sure the script doesn't quit until killed by something like
  # SIGINT.
  def run
    if @gui
      @gui.run
    else
      start(true)
      @inputs.each { |input| input.listener.join }
      stop
    end
  end

  def running?
    @running
  end

  # Send the message with the given +name+ to all outputs. Names are matched
  # case-insensitively.
  def send_message(name)
    _correct_case_name, msg = @messages[name.downcase]
    if !msg
      message("Message \"#{name}\" not found")
      return
    end

    @outputs.each { |out| out.midi_out(msg) }

    # If the user accidentally calls send_message in a filter at the end,
    # then the filter will return whatever this method returns. Just in
    # case, return nil instead of whatever the preceding code would return.
    nil
  end

  # Sends the +CM_ALL_NOTES_OFF+ controller message to all output
  # instruments on all 16 MIDI channels. If +individual_notes+ is +true+
  # send individual +NOTE_OFF+ messages to all notes as well.
  def panic(individual_notes=false)
    @outputs.each do |out|
      buf = [] of UInt8
      MIDI_CHANNELS.times do |chan|
        buf += [CONTROLLER + chan, CM_ALL_NOTES_OFF, 0]
        if individual_notes
          buf += (0..127).collect { |note| [NOTE_OFF + chan, note, 0] }.flatten
        end
      end
      out.midi_out(buf)
    end
  end
end
