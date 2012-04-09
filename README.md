## RadioVIS Generator

This is a small gem which allows you to quickly and simply generate slides (comprising of a complex, rendered and composited image, and some text) customised for your station from an SVG source file, a set of substitutions (which can be dynamically driven) and optionally an image to composite behind the SVG output.

The generator also includes a framework for specifying slide durations and intelligently pushing them to your Stomp broker.

It's designed to let any station plug it directly into their infrastructure with a minimal amount of coding and a simple process for non-technical content creators.

### What is RadioVIS?

RadioVIS is a [RadioDNS](http://radiodns.org/) application. It's designed for hybrid radio receivers (Broadcast audio plus IP back channel) but can be used on other platforms such as the internet in addition. A [much better description](http://radiodns.org/about-radiodns/) can be found on the RadioDNS website.

Simply put (though if you want the spec, [it's here](http://radiodns.org/documentation/)) RadioVIS lets receivers and audio player software show an image and a line of text next to your station, and allows for the use of push technologies to update which image and text the receiver is displaying at a given point in time. This allows for content mapped to the output of your station (such as 'Now Playing' information or information on the current show) to be generated and displayed to your users.

## Dependencies

RadioVIS Generator depends on Inkscape (which does not require a GUI) and the ImageMagick project (the 'convert' and 'composite' binaries).

Aside from those two tools, Ruby is required, along with RubyGems. Recent versions are recommended.

You'll also need a Stomp broker, though this can be on another system. You'll probably need a web server like nginx or Apache on your system, though.

RadioVIS Generator is tested on Linux. Other operating systems are supported in principle, but not tested.

## Installation and Usage

Installing is simple. Install the dependencies (on Ubuntu, that's `sudo apt-get install imagemagick inkscape` - add `ruby1.9-full` if you're missing Ruby), and then simply install the gem with `gem install radiovis-generator`. Congratulations, you're good to go!


You can test the installation out by using the simple command line program bundled with the generator - see `radiovis-generator --help` for options. This will cycle between the slides provided by the gem, and is intended as a really simple starting point for your own runner.


### Simple Usage

RadioVIS Generator comes bundled with a couple of basic templates - one which shows two pieces of information (intended for Now Playing slides), and one which shows just a large title. These will get you off the ground, or at least show you how to customise your slides.

To run RadioVIS Generator is very simple. I'm going to assume you can set up a folder on your system and point your web server at it, and that you've got a Stomp broker running. If this is all correct, then you can run a simple demo by creating a file like this:

```
require 'rubygems'
require 'radiovis-generator'
gen = RadioVISGenerator::Generator.new
options = {
  slides: [RadioVISGenerator::BrandingSlide.new, RadioVISGenerator::NowPlayingSlide.new],
  url: 'http://localhost/radiovis/', # The path on your web server pointing at..
  path: '/tmp/radiovis-output',       # This path on your filesystem!
  broadcast_parameters: 'fm/ecc/pi/freq', # See the RadioVIS spec for how to generate this.
  username: 'system',   # These details are for your Stomp broker.
  password: 'manager',
  host: 'localhost',
  port: 61613
}
gen.run(options)
```

Running this file will perpetually serve up RadioVIS images and text, and send out Stomp messages. You can use a tool like CasterPlay's RadioVIS Monitor to check everything is working. The console output will also tell you more or less what it's doing, or at least let you know if it's obviously not working!

### Customising

Customisation should simply be a matter of making a new subclass of `RadioVISGenerator::Slide`, making a new SVG file and if required a background image, and then adding the new subclass to your runner rotation. So let's say we want a simple slide which is going to have a rotating title and a background image.

```
class MyCustomSlide < RadioVISGenerator::Slide
  def generate
    return {
      '$$TITLE$$' => ['Some cool text!', 'Some other cool text!'].shuffle.first
    }
  end
  # We don't want this one displayed so often.
  def redisplay_delay
    20
  end
  # Specify our filename - this is messy because it's relative to the gem.
  def svg_filename
    return "/some/path/to/my-custom-slide.svg"
  end
  # We want a background image!
  def background_image
    return "/some/path/to/my-background.png"
  end
end
```

Now all we need to do is pass `MyCustomSlide.new` to our runner as a slide to consider in the rotation and we're done! We can customise the SVG file or the background image, adjust the text we're dynamically adding in our slide class, or add new dynamic elements through the same mechanism. The only limit is the lengths to which you're willing to figure out how to do things with SVG.


Loads more information on how to make your own custom slides can be found in the RDoc documentation or by simply reading the `slide.rb` file.


## Credits and Acknowledgements

* This software package was developed by James Harrison, originally as part of the OCD Broadcast Content Management System for [Insanity Radio](http://insanityradio.com).
* RadioDNS is supported by a [lot of people](http://radiodns.org/supporters/).
* The [Inkscape](http://inkscape.org/) project provides the kick-ass SVG to PNG converter and a really slick SVG editor.
* [ImageMagick](http://www.imagemagick.org/script/index.php) has yet to not appear in anything I've ever written. All the contributors rock.


## License

Copyright (c) 2012, James Harrison
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
* Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
* Neither the name of Insanity Radio nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL JAMES HARRISON OR INSANITY RADIO BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
