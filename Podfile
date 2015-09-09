source 'https://github.com/CocoaPods/Specs.git'
platform :ios, "7.0"

pod 'Appirater'
pod 'SWRevealViewController', '>=2.3.0'
pod 'JaspersoftSDK', :git => 'https://github.com/Jaspersoft/js-ios-sdk.git', :tag => '2.1'

post_install do |installer_representation|
  installer_representation.project.targets.each do |target|
    if target.name == "Pods-JaspersoftSDK"
      target.build_configurations.each do |config|
		if config.build_settings['GCC_PREPROCESSOR_DEFINITIONS']
          	config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] |= ['$(inherited)']
          elsif
			config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= ['$(inherited)']
		end

        if config.name == 'Debug'
          config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] |= ['__DEBUG__']
    	elsif config.name == 'Adhoc'
          config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] |= ['__ADHOC__']
        elsif config.name == 'Release'
          config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] |= ['__RELEASE__']
        end      
      end
    end
  end
end