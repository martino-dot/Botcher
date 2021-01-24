# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'Botch' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
  pod 'SwiftyStoreKit'
  pod 'ChromaColorPicker'
  pod 'UIColor_Hex_Swift'
  pod 'ReachabilitySwift'
  pod 'Valet'
  # Pods for Botch
 
  
  post_install do |installer|
      installer.pods_project.targets.each do |target|
          target.build_configurations.each do |config|
              config.build_settings['DEBUG_INFORMATION_FORMAT'] = 'dwarf'
          end
      end
  end


  target 'BotchTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'BotchUITests' do
    # Pods for testing
  end

end
