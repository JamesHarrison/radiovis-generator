Gem::Specification.new do |s|
  s.name        = 'radiovis-generator'
  s.version     = '0.1.1'
  s.date        = '2012-04-09'
  s.summary     = "A RadioVIS slide generator"
  s.description = "An extendable gem to generate slide images and text for RadioVIS systems and publish them in an intelligent rotation"
  s.authors     = ["James Harrison"]
  s.email       = 'james@talkunafraid.co.uk'
  s.files       = Dir["{lib}/**/*.rb", "templates/*", "*.md"]
  s.homepage    = 'http://jamesharrison.github.com/radiovis-generator'
  s.executables << 'radiovis-generator'
  s.license     = 'Modified BSD'
  s.post_install_message = "Thanks for installing! Please do visit http://jamesharrison.github.com/radiovis-generator and carefully read the documentation."
  s.requirements = "ImageMagick v6 or better, Inkscape"
  s.add_runtime_dependency 'trollop'
  s.add_runtime_dependency 'stomp'
end