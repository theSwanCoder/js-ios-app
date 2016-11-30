source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '8.0'

abstract_target 'AppPods' do
	pod 'Appirater', '2.0.5'
	pod 'SWRevealViewController', '2.3.0'
	pod 'JaspersoftSDK', :git => 'https://github.com/Jaspersoft/js-ios-sdk.git',  :branch => 'other_improvements', :subspecs => ['JSCore', 'JSSecurity', 'JSReportExtention']
	target 'TIBCO JasperMobile'
    target 'TIBCO JasperMobile Tests'
    target 'TIBCO JasperMobileUITests'
    target 'TIBCO JasperMobile Performance UITests'
end

post_install do |installer_representation|
  installer_representation.pods_project.targets.each do |target|
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
