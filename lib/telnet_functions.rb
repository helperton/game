class TelnetFunctions
  def self.handle_telnet(line, io)          # minimal Telnet
    line.gsub!(/([^\015])\012/, "\\1")      # ignore bare LFs
    line.gsub!(/\015\0/, "")                # ignore bare CRs
    line.gsub!(/\0/, "")                    # ignore bare NULs

    while line.index("\377")                # parse Telnet codes
      if line.sub!(/(^|[^\377])\377[\375\376](.)/, "\\1")
        # answer DOs and DON'Ts with WON'Ts
        io.print "\377\374#{$2}"
      elsif line.sub!(/(^|[^\377])\377[\373\374](.)/, "\\1")
        # answer WILLs and WON'Ts with DON'Ts
        io.print "\377\376#{$2}"
      elsif line.sub!(/(^|[^\377])\377\366/, "\\1")
        # answer "Are You There" codes
        io.puts "Still here, yes."
      elsif line.sub!(/(^|[^\377])\377\364/, "\\1")
        # do nothing - ignore IP Telnet codes
      elsif line.sub!(/(^|[^\377])\377[^\377]/, "\\1")
        # do nothing - ignore other Telnet codes
      elsif line.sub!(/\377\377/, "\377")
        # do nothing - handle escapes
      end
    end
    line
  end
end
