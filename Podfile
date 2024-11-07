source 'https://github.com/CocoaPods/Specs.git'
source 'https://zrepository.zoho.com/zohocorp/zoho/zohopodspecs.git'
source 'https://zrepository.zoho.com/zohocorp/user/Harisaravanan/Podspecs.git'

target 'MEMInstaller' do
  use_frameworks!
	
  pod 'ZCatalyst', '2.1.2'
  pod 'Zip'
  pod 'MEMToast'

  target 'MEMInstallerTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'MEMInstallerUITests' do
    # Pods for testing
  end

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
    end
  end
end
