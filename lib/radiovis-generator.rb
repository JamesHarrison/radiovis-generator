require 'stomp'

module RadioVISGenerator
  class Generator
    def initialize
      Generator.has_dependencies?
    end

    # Runs the generator!
    # This does all the tying together of things and Stomp interaction.
    # The generator accepts a hash of options:
    #   slides - An array of Slide instances.
    #   url - The root URL at which the pictures can be found from the outside world, ie 'http://blah.com/system/radiovis-images/'.
    #   path - The root path where we should write the images, ie '/opt/www/website/public/system/radiovis-images'
    #   broadcast_parameters - The broadcast parameters for your station in RadioVIS topic format, ie 'fm/ECC/PI/FREQUENCY' for FM (like 'fm/ce1/c08f/10320' for Insanity Radio 103.2 FM)
    #   username - The Stomp username
    #   password - The Stomp password
    #   host - The Stomp host
    #   port - The Stomp port
    # Sensible defaults are provided for Stomp, but you should set them explicitly.
    def run(options)
      defaults = {
        slides: [],
        url: 'http://localhost/radiovis/',
        path: '/tmp/radiovis-output',
        broadcast_parameters: 'fm/ecc/pi/freq',
        username: 'system',
        password: 'manager',
        host: 'localhost',
        port: 61313
      }
      options = defaults.merge(options)
      raise ArgumentsError, "No slide instances provided!" unless options[:slides].size > 0
      puts "Generator starting - parameters #{options.inspect}"
      begin
        conn = Stomp::Connection.open options[:username], options[:password], options[:host], options[:port], false
        while true do
          # Okay - so here's the plan.
          # We have a bunch of Slide subclasses which contain what we want.
          # Every so often we check to see if any need rendering and render whichever has the highest priority.
          slides_to_render = []
          options[:slides].each do |slide|
            slides_to_render.push(slide) if slide.changed?
          end
          # If we've got nothing that's changed, pick a redisplay instead.
          if slides_to_render.size == 0
            options[:slides].each do |slide|
              slides_to_render.push(slide) if slide.redisplay?
            end
          end
          # Pick the lowest priority.
          slides_to_render.sort_by!{|slide|slide.priority}
          slide = slides_to_render.reverse[0] rescue nil
          if slide
            # Go for it!
            puts "Rendering #{slide.inspect}"
            puts "Chosen from #{slides_to_render.inspect}"
            slide_output = slide.render(options[:path])

            # Now we go ahead and send those messages.
            image_topic = "/topic/#{options[:broadcast_parameters]}/image"
            text_topic  = "/topic/#{options[:broadcast_parameters]}/text"
            image_message = "SHOW "+options[:url]+slide_output[:image_small]
            text_message  = "TEXT "+slide_output[:text]
            puts "Publishing Stomp messages"
            puts " - #{image_topic} <= #{image_message}"
            puts " - #{text_topic} <= #{text_message}"
            conn.publish(image_topic, image_message, {'persistent'=>'false'})
            conn.publish(text_topic, text_message, {'persistent'=>'false'})
            puts "Done, waiting #{slide.display_time} seconds to let people read this slide."
            # Sleep for this long before we display anything else.
            sleep slide.display_time
          else
            puts "No slide to render, sleeping a second."
            sleep 1
          end
        end
      #rescue Exception => e
      #  puts "Got exception #{e}!"
      #  conn.disconnect rescue nil
      #  conn = nil
      #  sleep 5
      #  retry
      end
    end

    def self.has_dependencies?
      unless self.which('inkscape')
        raise SystemCallError, "Inkscape is required to use this library.\nYou can install it on Ubuntu/Debian with 'sudo apt-get install inkscape'. (And don't worry, it works headlessly and won't install a full GUI stack).\nSpecifically I need 'inkscape' in my PATH."
      end
      unless self.which('convert')
        raise SystemCallError, "ImageMagick is required to use this library.\nYou can install it on Ubuntu/Debian with 'sudo apt-get install imagemagick'.\nSpecifically I need 'convert' in my PATH."
      end
      unless self.which('composite')
        raise SystemCallError, "ImageMagick is required to use this library.\nYou can install it on Ubuntu/Debian with 'sudo apt-get install imagemagick'.\nSpecifically I need 'composite' in my PATH."
      end
    end
    private
    # Utility method to identify if a program is available and executable.
    def self.which(cmd)
      exts = ENV['PATHEXT'] ? ENV['PATHEXT'].split(';') : ['']
      ENV['PATH'].split(File::PATH_SEPARATOR).each do |path|
        exts.each { |ext|
          exe = "#{path}/#{cmd}#{ext}"
          return exe if File.executable? exe
        }
      end
      return nil
    end
  end
end

require 'radiovis-generator/slide'
require 'radiovis-generator/slides/branding_slide'
require 'radiovis-generator/slides/now_playing_slide'

