Pod::Spec.new do |s|
    s.name             = 'HubtelMobileMerchantCheckoutSdk'
    s.version          = '0.1.0'
    s.summary          = 'The Hubtel Checkout Library is a convenient and easy-to-use library that simplifies the process of implementing a checkout flow in your iOS application.'
  
    s.homepage         = 'https://github.com/hubtel/hubtel-mobile-ios-merchant-checkout-sdk'
    s.license          = { :type => 'MIT', :file => 'LICENSE.md' }
    s.author           = { 'Albany Buipe' => 'mohammedarahman96@gmail.com' }
    s.source           = { :git => 'https://github.com/hubtel/hubtel-mobile-ios-merchant-checkout-sdk.git', :tag => s.version.to_s }
  
    s.ios.deployment_target = '13.0'
    s.swift_version = '5.5'
  
    s.source_files = 'Sources/Hubtel_Checkout/**/*'
  end