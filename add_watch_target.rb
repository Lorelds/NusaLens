require 'xcodeproj'

project_path = 'NusaLens.xcodeproj'
project = Xcodeproj::Project.open(project_path)

target_name = 'NusaLensWatch'

# Check if target already exists
if project.targets.any? { |t| t.name == target_name }
  puts "Target already exists."
  exit 0
end

# Add target
watch_target = project.new_target(:application, target_name, :watchos, '10.0')

# Create a group for the new target files (regular group)
watch_group = project.main_group.new_group(target_name, target_name)

# Create file references for new watch files
app_file = watch_group.new_file('NusaLensWatchApp.swift')
content_file = watch_group.new_file('WatchDailyTriviaView.swift')

# Add to build phase
watch_target.source_build_phase.add_file_reference(app_file)
watch_target.source_build_phase.add_file_reference(content_file)

# Share models and services by creating direct file references
shared_files = [
  'NusaLens/Models/Budaya.swift',
  'NusaLens/Models/CulturalCategory.swift',
  'NusaLens/Models/Trivia.swift',
  'NusaLens/Services/CultureService.swift',
  'NusaLens/Services/TriviaService.swift'
]

shared_files.each do |path|
  file_ref = watch_group.new_file("../" + path)
  watch_target.source_build_phase.add_file_reference(file_ref)
  puts "Added #{path} to watch target"
end

# Build settings
watch_target.build_configurations.each do |config|
  config.build_settings['PRODUCT_BUNDLE_IDENTIFIER'] = "Yuriel.NusaLens.watchkitapp"
  config.build_settings['TARGETED_DEVICE_FAMILY'] = "4"
  config.build_settings['SDKROOT'] = "watchos"
  config.build_settings['WATCHOS_DEPLOYMENT_TARGET'] = "10.0"
  config.build_settings['SWIFT_VERSION'] = "5.0"
  config.build_settings['INFOPLIST_KEY_WKCompanionAppBundleIdentifier'] = "Yuriel.NusaLens"
  config.build_settings['INFOPLIST_KEY_UIApplicationSceneManifest_Generation'] = "YES"
  config.build_settings['INFOPLIST_KEY_UILaunchScreen_Generation'] = "YES"
  # Support SwiftUI app lifecycle
  config.build_settings['GENERATE_INFOPLIST_FILE'] = "YES"
end

project.save
puts "Successfully added WatchOS target."
