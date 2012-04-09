require 'fileutils'
class RadioVISGenerator::Slide
  # Generate the substitution hash to process on this run. This is where we add our dynamic content!
  # Returns a hash where "$$TARGET$$" => "Content", where $$TARGET$$ is the target string to replace in the SVG and Content is the substitute.
  # This is passed to RadioVISGenerator::Slide.rewrite_svg
  def generate
    return {}
  end

  # Generate the text to display alongside this slide.
  def text
    return "Default slide text - RadioVIS Generator"
  end

  # Has this slide changed since last rendered?
  # Reset anything you need to in the Slide#generate method.
  # For instance, if I'm showing the current show or now playing, I'd check if the current track on air
  #   was the same as the one I'd stored last time I'd rendered. If it were different I'd return true.
  #   Then in Slide#generate, I'd store the current track on air.
  # This means we can get very prompt updates on realtime events - maximum delay defined by your largest
  #   display_time of all the slides, ie 5 seconds with nothing overridden.
  def changed?
    return false
  end

  # What is the priority of this slide? Lower numbers takes precedence. Default 50.
  def priority
    return 50
  end

  # How long should we display this slide for at a minimum? Values under 5 are rarely good.
  def display_time
    return 5
  end

  # How long should we wait between redisplays if we've got nothing better to do (ie no content changed)?
  def redisplay_delay
    return 23
  end

  # What image makes the background of this slide, and should be composited over it?
  # Return nil to skip the composition stage and just display the SVG output.
  # Defaults to nil.
  def background_image
    return nil
  end

  # What SVG file are we going to render?
  # Defaults to an empty slide.
  def svg_filename
    return "#{File.expand_path(File.dirname(File.dirname(__FILE__)))}/templates/empty-slide.svg"
  end

  # Okay, show's over!

  # That's it. Everything up there, define in your subclasses if you want to override them. 

  # Set up the slide. Just sets the last time this slide was rendered up.
  def initialize
    @last_render_time = Time.now
  end

  # Have we gotten bored enough to just show this again, assuming it's not been too little time
  # (as defined in Slide#redisplay_delay)
  def redisplay?
    if @last_render_time < Time.now - 15
      return true
    end
    return false
  end


  # Render this slide, returns a hash with image_big, image_small, output_path, name and text. Paths returned are relative to the provided output_path.
  # Will create the output path if needed.
  # Shouldn't be overriden unless you know what you're doing.
  # Calls Slide#generate and Slide#text to get dynamic content and then spits out some images.
  def render(output_path)
    # Reset time-based cycling
    @last_render_time = Time.now
    # Make sure our output path exists
    FileUtils.mkdir_p(output_path) rescue nil
    Dir.mkdir('/tmp/radiovis-generator') rescue nil # Make our temporary storage
    RadioVISGenerator::Slide.rewrite_svg(svg_filename, "/tmp/#{self.name}.svg", self.generate)
    if background_image
      RadioVISGenerator::Slide.render_svg("/tmp/#{self.name}.svg", "/tmp/#{self.name}-precomp.png")
      RadioVISGenerator::Slide.composite("/tmp/#{self.name}-precomp.png", background_image, File.join(output_path, "#{self.name}-640x480.png"))
    else
      RadioVISGenerator::Slide.render_svg("/tmp/#{self.name}.svg", File.join(output_path, "#{self.name}-640x480.png"))
    end
    FileUtils.rm_rf('/tmp/radiovis-generator') rescue nil # Clean up after ourselves
    # Make our smaller-res version
    RadioVISGenerator::Slide.resize_to_fit(File.join(output_path, "#{self.name}-640x480.png"), File.join(output_path, "#{self.name}-320x240.png"), '320x240')
    return {
      image_big: "#{self.name}-640x480.png",
      image_small: "#{self.name}-320x240.png",
      text: self.text,
      output_path: output_path,
      name: self.name
    }
  end

  # Returns the name of this slide as a friendlyish string to be used in output image names.
  def name
    self.class.to_s.downcase.gsub("radiovisgenerator::","")
  end

  # Rewrites an SVG at a given input path with the information in the given hash to the given output path.
  # Hash is of the format "$$TARGET$$" => "Content", where $$TARGET$$ is the target string to replace in the SVG and Content is the substitute.
  def self.rewrite_svg(in_path, out_path, sub_hash)
    svg_input = File.open(in_path).read()
    sub_hash.each_pair do |k,v|
      svg_input = svg_input.gsub(k,v)
    end
    File.open(out_path, 'w'){|f|f<<svg_input}
  end

  # Renders an SVG to a PNG
  def self.render_svg(in_path, out_path)
    `inkscape -f #{in_path} -e #{out_path}`
  end

  # Resize and (if needed) crop to the size of a slide (640x480 by default), using center gravity.
  def self.resize_to_fit(in_path, out_path, size='640x480')
    `convert #{in_path} -resize #{size}^ -gravity center -extent #{size} #{out_path}`
  end

  # Composite two images to another image. Center gravity.
  def self.composite(top_in_path, bottom_in_path, out_path)
    `composite -gravity center #{top_in_path} #{bottom_in_path} #{out_path}`
  end

end
