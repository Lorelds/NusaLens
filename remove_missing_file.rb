require 'xcodeproj'
project = Xcodeproj::Project.open('NusaLens.xcodeproj')
watch_target = project.targets.find { |t| t.name == 'NusaLensWatch' }

watch_target.source_build_phase.files_references.each do |file_ref|
  if file_ref.path && file_ref.path.include?('CulturalCategory.swift')
    watch_target.source_build_phase.remove_file_reference(file_ref)
    file_ref.remove_from_project
  end
end

project.save
puts "Removed CulturalCategory.swift from watch target"
