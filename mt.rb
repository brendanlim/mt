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
  
  def handle_request(args)
    return if args.length == 0
    case args[0].downcase.to_sym
      when :n
        self.next_track
      when :p
        self.previous_track
      when :track
        self.print_current_track
      when :pause
        self.pause
      when :play
        self.play
      when :search
        args.delete_at(0)
        self.search_for(args.join(" "))
      else
        puts "Invalid argument"
    end
  end
end

if ARGV.include?("--help")
  puts "Usage: mt [argument]"
  puts ""
  puts "Available Commands: "
  puts "  n         # Play the next track"
  puts "  p         # Play the previous track"
  puts "  track     # Prints the current track"
  puts "  play      # Resumes play if paused"
  puts "  pause     # Pauses playback"
  puts "  search    # Searches for any string past this command"
else
  mt = Mt.new(ARGV)  
end
