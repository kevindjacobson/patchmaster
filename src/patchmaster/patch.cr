class Patch

  property name, start_bytes, stop_bytes, connections

  def self.empty
    @@empty ||= Patch.new("Unnamed", [] of UInt8, [] of UInt8)
  end

  def initialize(@name : String, @start_bytes : Array(UInt8), @stop_bytes : Array(UInt8))
    @connections = [] of Connection
    @running = false
  end

  def <<(conn)
    @connections << conn
  end

  def inputs
    @connections.map(&:input).uniq
  end

  # Send start_bytes to each connection.
  def start
    unless @running
      @connections.each { |conn| conn.start(@start_bytes) }
      @running = true
    end
  end

  def running?
    @running
  end

  # Send stop_bytes to each connection, then call #stop on each connection.
  def stop
    if @running
      @running = false
      @connections.each { |conn| conn.stop(@stop_bytes) }
    end
  end
end
