workspace 'Classy'

platform :ios, '9.0'

project 'Example/ClassyExample'
  
target 'ClassyExample' do
  pod 'Classy', :path => './'
end

target 'ClassyTestsLoader' do
  project 'Tests/ClassyTests'
  pod 'Classy', :path => './'
end

target 'ClassyTests' do
  project 'Tests/ClassyTests'
  pod 'Expecta'
  pod 'OCMockito'
end

# add settings needed to generate test coverage data
post_install do |installer|

  COV_TARGET_NAME = "Pods-ClassyTestsLoader"
  EXPORT_ENV_PHASE_NAME = "Export Environment Vars"
  EXPORT_ENV_PHASE_SCRIPT = "export | egrep '( BUILT_PRODUCTS_DIR)|(CURRENT_ARCH)|(OBJECT_FILE_DIR_normal)|(SRCROOT)|(OBJROOT)' > " << File.join(installer.config.installation_root, "/script/env.sh") 

  # find target
  classy_pods_target = installer.pods_project.targets.find{ |target| target.name == COV_TARGET_NAME }
  unless classy_pods_target
   raise ::Pod::Informative, "Failed to find '" << COV_TARGET_NAME << "' target"
  end
       
  # add build settings
  classy_pods_target.build_configurations.each do |config|
    config.build_settings['GCC_GENERATE_TEST_COVERAGE_FILES'] = 'YES'
    config.build_settings['GCC_INSTRUMENT_PROGRAM_FLOW_ARCS'] = 'YES'
  end

  # add build phase
  phase = classy_pods_target.shell_script_build_phases.select{ |bp| bp.name == EXPORT_ENV_PHASE_NAME }.first ||
    classy_pods_target.new_shell_script_build_phase(EXPORT_ENV_PHASE_NAME)
      
  phase.shell_path = "/bin/sh"
  phase.shell_script = EXPORT_ENV_PHASE_SCRIPT
  phase.show_env_vars_in_log = '0'

end
