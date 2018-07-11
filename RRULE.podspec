Pod::Spec.new do |s|

  s.name         = "RRULE"
  s.version      = "0.5.0"
  s.summary      = "Swift rrule library for working with recurrence rules of calendar dates."
  s.description  = <<-DESC
RRULE is a library that can handle RRules with Swift.
This library was created by forking https://github.com/teambition/RRuleSwift.
                   DESC
  s.homepage     = "https://github.com/1amageek/RRULE"
  s.license      = { :type => "MIT", :file => "LICENSE.md" }
  s.author             = { "1amageek" => "tmy0x3@icloud.com" }
  s.social_media_url   = "http://twitter.com/1amageek"
  s.ios.deployment_target = "11.0"
  s.osx.deployment_target = "10.10"
  #s.watchos.deployment_target = "3.0"
  #s.tvos.deployment_target = "11.0"
  s.source       = { :git => "https://github.com/1amageek/RRULE.git", :tag => "#{s.version}" }
  s.source_files = "Sources/**/*.{swift, js}"
  s.framework = "EventKit"
  s.framework = "JavaScriptCore"

end
