require "rubygems"
require "bundler"
Bundler.setup
require "eventmachine"
require "fraggle"
require "json"

class Gorg
  CTL_RE = /^\/ctl\//

  def initialize(opts)
    @log = !opts[:quiet]
    @path = opts[:path]
  end

  def dump
    log("dump event=open")
    file = @path ? File.open(@path, "w") : $stdout
    log("dump event=run")
    EM.run do
      log("dump event=connect")
      client = Fraggle.connect
      log("dump event=req")
      client.walk(nil, "/**") do |r|
        log("dump event=res path=#{r.path}")
        file.puts(JSON.dump({"path" => r.path, "value" => r.value}))
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
    file = @path ? File.open(@path, "r") : $stdin
    log("load event=run")
    finishing = false
    EM.run do
      log("load event=connect")
      client = Fraggle.connect
      while (line = file.gets)
        data = JSON.parse(line)
        if data["path"].match(CTL_RE)
          log("load event=skip path=#{data["path"]}")
        else
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
    $stderr.puts("gorg #{msg}") if @log
  end
end
