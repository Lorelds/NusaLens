require 'xcodeproj'

project = Xcodeproj::Project.open('NusaLens.xcodeproj')
watch_target = project.targets.find { |t| t.name == 'NusaLensWatch' }

watch_target.build_configurations.each do |config|
  config.build_settings['PRODUCT_NAME'] = "NusaLensWatch"
  # Standard settings for watchOS apps
  config.build_settings['SKIP_INSTALL'] = "YES"
end

project.save
puts "Fixed PRODUCT_NAME for NusaLensWatch"
