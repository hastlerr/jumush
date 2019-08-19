# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'
inhibit_all_warnings!

target 'Tinder' do
    use_frameworks!

    pod 'Firebase/Auth'
    pod 'Firebase/Firestore'
    pod 'Firebase/Core'
    pod 'AKMaskField'
    pod 'PKHUD'
    pod 'Koloda'
    pod 'IQKeyboardManagerSwift'
    pod 'ObjectMapper'
    pod 'Firebase/Storage'
    pod 'SDWebImage'
    pod 'GrowingTextView', '0.5'
    pod 'Firebase/Messaging'
    
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '4.1'
        end
    end
end
