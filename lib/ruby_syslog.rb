require 'socket'

module RubySyslog
  class Logger
    SEVERITIES = {
      :emergency => 0,      # system is unusable
      :alert => 1,          # action must be taken immediately
      :critical => 2,       # critical conditions
      :error => 3,          # error conditions
      :warning => 4,        # warning conditions
      :notice => 5,         # normal but significant condition
      :informational => 6,  # informational messages
      :info => 6,           # informational messages (short name for the previous)
      :debug => 7           # debug-level messages
    }
    
    FACILITIES = {
      :kernel => 0,         # kernel messages
      :user_level => 1,     # user-level messages
      :mail => 2,           # mail system
      :daemons => 3,        # system daemons
      :security => 4,       # security/authorization messages
      :internal => 5,       # messages generated internally by syslogd
      :printer => 6,        # line printer subsystem
      :network => 7,        # network news subsystem
      :uucp => 8,           # UUCP subsystem
      :clock => 9,          # clock daemon
      :security1 => 10,     # security/authorization messages
      :ftp => 11,           # FTP daemon
      :ntp => 12,           # NTP subsystem
      :log_audit => 13,     # log audit
      :log_alert => 14,     # log alert
      :clock1 => 15,        # clock daemon
      :local0 => 16,        # local use 0
      :local1 => 17,        # local use 1
      :local2 => 18,        # local use 2
      :local3 => 19,        # local use 3
      :local4 => 20,        # local use 4
      :local5 => 21,        # local use 5
      :local6 => 22,        # local use 6
      :local7 => 23         # local use 7
    }
    
    def initialize(host, facility, tag)
      @host = host
      facility = FACILITIES[facility] if facility.is_a? Symbol
      @facility = facility
      @tag = tag
      @socket = UDPSocket.new
    end
    
    def log(severity, message, time = nil)
      severity = SEVERITIES[severity] if severity.is_a? Symbol
      time ||= Time.now
      hostname = Socket.gethostname
      day = time.strftime('%b %d').sub(/0(\d)/, ' \\1')
      send "<#{@facility * 8 + severity}>#{day} #{time.strftime('%T')} #{hostname} #{@tag}: #{message}"
    end
    
    def send(data)
      @socket.connect(@host, 514)
      @socket.send(data, 0)
    ensure
      @socket.close rescue nil
    end
    private :send
    
    SEVERITIES.keys.each do |severity|
      define_method severity do |message|
        log(severity, message)
      end
    end
  end
end
