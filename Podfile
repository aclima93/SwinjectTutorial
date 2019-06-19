platform :ios, '10.0'
use_frameworks!

target 'Bitcoin Adventurer' do
  pod 'Swinject', '~> 2.1'
  pod 'SwinjectAutoregistration', '~> 2.1'
  pod 'SwinjectStoryboard', :git => 'https://github.com/mdyson/SwinjectStoryboard.git', :branch => 'master'
  
  target 'Bitcoin Adventurer Tests' do
    pod 'Swinject', '~> 2.1'
    pod 'SwinjectAutoregistration', '~> 2.1'
  end
  
  post_install do |installer|
    installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings['SWIFT_VERSION'] = '5.0'
      end
    end
  end
  
end

