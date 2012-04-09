class RadioVISGenerator::NowPlayingSlide < RadioVISGenerator::Slide
  # In here I'd do some clever stuff if I were being clever. But I'm not.
  # I'm just an example slide. You're clever, right? You can help me out here!
  def generate
    return {
      '$$STATIONNAME$$' => 'Your Radio Station',
      '$$NOWPLAYING$$'  => 'Some Track is Playing'
    }
  end
  # Specify our filename - this is messy because it's relative to the gem.
  def svg_filename
    return "#{File.expand_path(File.dirname(File.dirname(File.dirname(File.dirname(__FILE__)))))}/templates/now-playing-slide.svg"
  end
end