#!/usr/local/bin/macruby
framework "ScriptingBridge"

class Mt
  def initialize(args)
    @itunes = SBApplication.applicationWithBundleIdentifier('com.apple.iTunes')
    handle_request(args)
  end
  
  def next_track
    @itunes.nextTrack
    self.print_current_track
  end

  def previous_track
    @itunes.previousTrack
    self.print_current_track
  end

  def print_current_track
    self.print_track(@itunes.currentTrack)
  end

  def print_track(track)
    puts "#{track.artist} - #{track.name}"
  end
  
  def play
    @itunes.playpause
    self.print_current_track
  end
  
  def pause
    @itunes.pause
  end
  
  def search_for(term)
    tracks = @itunes.sources.objectWithName("Library").playlists[0].searchFor(term, only:0)
    unless tracks.nil?
      tracks.each {|x| puts "[#{x.databaseID}] #{x.artist} - #{x.name}" }
    else
      puts "Sorry, nothing matched #{search_term}"
    end
  end
  
  def search_and_play(term)
    script  = "tell application \"iTunes\"\n"
    script += " play first item of (search first library playlist for \"#{term}\")\n"
    script += "end tell"
    pnt = Pointer.new_with_type("@")
    as = NSAppleScript.alloc.initWithSource(script)
    as.executeAndReturnError(pnt)
    self.print_current_track
  end
  
  def handle_request(args)
    return if args.length == 0
    case args[0].downcase.to_sym
      when :n
        self.next_track
      when :p
        self.previous_track
      when :track
        self.print_current_track
      when :pp
        self.play
      when :play
        args.delete_at(0)
        self.search_and_play(args.join(" "))
      when :search
        args.delete_at(0)
        self.search_for(args.join(" "))
      else
        puts "'#{args[0]}' is an invalid command\n\n"
        Mt.help
    end
  end
  
  def self.help
    puts "Usage: mt [command]"
    puts ""
    puts "Available Commands: "
    puts "  n                       # Play the next track"
    puts "  p                       # Play the previous track"
    puts "  pp                      # Play/pause the current track"
    puts "  track                   # Prints the current track"
    puts "  search                  # Searches for any string past this command"
    puts "  play [search term]      # Searches and plays first item that matches search"
    puts ""
    puts "    e.g., mt play deadmau5 ghosts  #=> Deadmau5 - Ghosts N Stuff"
    puts "    e.g., mt play ghosts stuff     #=> Deadmau5 - Ghosts N Stuff"
  end
end

ARGV.include?("--help") ? Mt.help : mt = Mt.new(ARGV)
