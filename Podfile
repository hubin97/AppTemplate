# Uncomment the next line to define a global platform for your project
platform :ios, '14.0'

source 'https://github.com/CocoaPods/Specs.git'

#忽略引入库的所有警告
inhibit_all_warnings!

target 'AppTemplate' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
  
  pod 'RxSwift'
  pod 'RxCocoa'
  pod 'RxGesture'
  pod 'NSObject+Rx'

  pod 'MMKV'
  pod 'IQKeyboardManagerSwift'
  pod 'SnapKit'
  pod 'MJRefresh'
  pod 'DZNEmptyDataSet'
  pod 'Kingfisher', '~> 8.0'
  pod 'KingfisherWebP'
  #pod 'KingfisherSVG'
  #pod 'SVGKit'
  #pod 'Macaw', '~> 0.9.0'

  pod 'R.swift'
  pod 'SwiftLint', :configurations => ['Debug']
  pod 'Bugly'
  
  # Pods for AppStart
  pod 'AppStart', :path => '../AppStart'

#  pod 'AppStart'#, :path => './PodsRepo'
  pod 'Router', :path => './PodsRepo'
  pod 'Demo', :path => './PodsRepo'

end

# 导入 base_config_setup.rb 文件
require_relative './AppTemplate/Scripts/base_config_setup.rb'

# 修改依赖库的配置
post_install do |installer|
  base_config_setup(installer)
  installer.pods_project.targets.each do |target|
      # Enable tracing resources
      if target.name == 'RxSwift'
        target.build_configurations.each do |config|
          if config.name == 'Debug'
            config.build_settings['OTHER_SWIFT_FLAGS'] ||= ['-D', 'TRACE_RESOURCES']
          end
        end
      end
      #
      target.build_configurations.each do |config|
          config.build_settings['SWIFT_VERSION'] = '5.0'
          config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
      end
  end
end
