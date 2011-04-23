require "rubygems"
require "eventmachine"
require "fraggle"
require "json"

class Gorg
  CTL_RE = /^\/ctl\//

  def initialize(opts)
    @log = !!opts[:log]
    @path = opts[:path]
  end

  def dump
    log("dump event=open")
    file = File.open(@path, "w")
    log("dump event=run")
    EM.run do
      log("dump event=connect")
      client = Fraggle.connect
      log("dump event=req")
      client.walk(nil, "/**") do |r|
        log("dump event=res path=#{r.path}")
        if !r.path.match(CTL_RE)
          file.puts(JSON.dump({"path" => r.path, "value" => r.value}))
        end
      end.done do
        log("dump event=stop")
        EM.stop
        log("dump event=close")
        file.close
        log("dump event=finish")
      end
    end
  end

  def load
    log("load event=open")
    file = File.open(@path, "r")
    log("load event=run")
    finishing = false
    EM.run do
      log("load event=connect")
      client = Fraggle.connect
      while (line = file.gets)
        data = JSON.parse(line)
        log("load event=req path=#{data["path"]}")
        client.set(-1, data["path"], data["value"]) do
          log("load event=res path=#{data["path"]}")
          if finishing
            log("load event=stop")
            EM.stop
            log("load event=finish")
          end
        end
      end
      log("load event=finishing")
      finishing = true
      log("load event=close")
      file.close
    end
  end

  def sink
    raise("sink'ing, how does it work?")
  end

  def log(msg)
    puts("gorg #{msg}") if @log
  end
end
