class RadioVISGenerator::BrandingSlide < RadioVISGenerator::Slide
  # Man, NowPlayingSlide thinks he's got problems. I'm a complete idiot compared to that guy.
  # Hey, want to help me out? Maybe add some functionality to me?
  def generate
    return {
      '$$STATIONNAME$$' => 'Your Radio Station'
    }
  end
  # I'm just an example slide so I don't actually have a background image bundled.
  # But here I'd return a full path to whatever I wanted behind my SVG with all the SVG's shiny opacity.
  def background_image
    return nil
  end
  # We don't want this one displayed so often.
  def redisplay_delay
    20
  end
  # And it's lower priority. 
  def priority
    25
  end
  # Specify our filename - this is messy because it's relative to the gem.
  def svg_filename
    return "#{File.expand_path(File.dirname(File.dirname(File.dirname(__FILE__))))}/templates/branding-slide.svg"
  end
end