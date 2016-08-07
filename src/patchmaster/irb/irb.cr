$dsl = nil

class IRB

  property dsl                  # read-only

  def initialize
    @dsl = DSL.new
    @dsl.song("IRB Song")
    @dsl.patch("IRB Patch")
  end

  # For bin/patchmaster.
  def run
    ::IRB.start
  end
end

def dsl
  IRB.instance.dsl
end

# Return the current (only) patch.
def patch
  dsl.patch
end

# Stop and delete all connections.
def clear
  patch.stop
  patch.connections = [] of Connection
  patch.start
end

def pm_help
  puts IO.read(File.join(File.dirname(__FILE__), "irb_help.txt"))
end

# The "panic" command is handled by the DSL instance. This version
# (+panic!+) tells that +panic+ to send all all-notes-off messages.
def panic!
  PatchMaster.instance.panic(true)
end

def method_missing(sym, *args)
  pm = PatchMaster.instance
  if dsl.respond_to?(sym)
    patch.stop
    dsl.send(sym, *args)
    if sym == :input || sym == :inp
      pm.inputs.last.start
    end
    patch.start
  elsif pm.respond_to?(sym)
    pm.send(sym, *args)
  else
    super
  end
end
