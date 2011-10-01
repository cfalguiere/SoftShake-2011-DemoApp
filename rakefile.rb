
# rakefile.rb was written by Sylvain Rousseau and modified by Claude Falguiere
#
# Usage:
# rake clean build test package deploy
#
# Description
# use the XCode command line tools to build, test and package
# add additional step to build and rsync a bundle for the enterprise mobile store
#
# Dependencies
# config.yaml, publish.bash, logFilter.awk
#

# sudo gem install json plist
require 'rubygems'
require 'rake/classic_namespace'
require 'rake/clean'
require 'yaml'
require 'json'
require 'plist'

# read config
CONFIG = YAML.load_file('SoftwareFactory/config.yaml')
APPNAME = CONFIG['app_name']
SERVER = CONFIG['server']
PROVPROFILE_ID = CONFIG['provisioning_profile']
STOREPATH = CONFIG['store_path']

# evaluate pathes
PROVPROFILE_FILE = "SoftwareFactory/#{PROVPROFILE_ID}.mobileprovision"
PROVPROFILE_PATH = File.expand_path(PROVPROFILE_FILE)

# get version
osVersion = `awk '/IPHONEOS_DEPLOYMENT_TARGET/ {print $3}' #{APPNAME}.xcodeproj/project.pbxproj | head -1`.sub(';', '').strip
devices_family = `awk '/TARGETED_DEVICE_FAMILY/ {print $3}' #{APPNAME}.xcodeproj/project.pbxproj | head -1`.gsub(/[;"]/, '').strip.split(',')

CONFIG.merge!(Plist::parse_xml("#{APPNAME}/#{APPNAME}-Info.plist")).merge!({'osVersion' => osVersion, 'devices_family' => devices_family})
CLEAN.include('pkg', "#{APPNAME}*.tgz", 'build')

# set log filter
LOG_FILTER_PIPE = "| awk -f SoftwareFactory/logFilter.awk"

task :import_provisioning do
  lines1 = lines2 = nil
  found = false
  File.open(PROVPROFILE_PATH) {|f| lines1 = f.readlines}
  FileList["/Users/#{`whoami`.strip}/Library/MobileDevice/Provisioning Profiles/*"].each do |file|
    File.open(file) {|f| lines2 = f.readlines}
    found = lines1 == lines2
    break if found
  end
  sh "open #{PROVPROFILE_PATH}" if not found
end

desc("Build Release configuration")
task :build => :import_provisioning do 
  puts "BUILD application #{APPNAME}"
  command = "xcodebuild -project \"#{APPNAME}.xcodeproj\" -target \"#{APPNAME}\" -sdk iphoneos -configuration \"Release\" CODE_SIGN_IDENTITY=\"#{CONFIG['sign']}\""
  sh "#{command} build #{LOG_FILTER_PIPE}"
end

desc("Launch test")
task :test do
  puts "TEST application #{APPNAME}"
  command = "xcodebuild -project \"#{APPNAME}.xcodeproj\" -target \"#{APPNAME}Tests\" -sdk iphonesimulator -configuration \"Release\" CODE_SIGN_IDENTITY=\"#{CONFIG['sign']}\" TEST_HOST= "
  #command = "xcodebuild -project \"#{APPNAME}.xcodeproj\" -target \"#{APPNAME}Tests\" -sdk iphonesimulator -configuration \"Release\" CODE_SIGN_IDENTITY=\"#{CONFIG['sign']}\" TEST_HOST=build/Release-iphoneos/#{APPNAME}.app/#{APPNAME}"
  sh "#{command} build $LOG_FILTER_PIPE"
end

abbreviated_commit_hash = `git log -1 --pretty=format:%h`
DIR = "pkg/#{CONFIG['CFBundleVersion']}"
directory DIR

multitask :ipa_files => [:build, :test, DIR]

def devices devices_family
  devices_family.map do |device|
    case device
    when '1'
      'iPhone'
    when '2'
      'iPad'
    end
  end.join(' - ')
end

JSON_FILE = "#{DIR}/#{APPNAME}.json"
file JSON_FILE => DIR do
  file = File.new(JSON_FILE, 'w')
  data = {:version => "#{CONFIG['CFBundleVersion']}-#{abbreviated_commit_hash}", 
    :icon => CONFIG['CFBundleIconFiles'][0], 
    :title => APPNAME,
    :osVersion => CONFIG['osVersion'],
    :devices => devices(CONFIG['devices_family'])}
  file.write JSON data
  file.close
end

PLIST_FILE = "#{DIR}/#{APPNAME}.plist"
file PLIST_FILE => DIR do
  url_prefix= "http://#{SERVER}#{STOREPATH}/apps/#{APPNAME}/#{CONFIG['CFBundleVersion']}/"
  data = {'items', ['assets'=> [{'kind' => 'software-package', 'url' => "#{url_prefix}#{APPNAME}.ipa"},
                                {'kind' => 'full-size-image', 'needs-shine' => true, 'url' => "#{url_prefix}iTunesArtwork.jpg"},
                                {'kind' => 'display-image', 'needs-shine' => true, 'url' => "#{url_prefix}#{CONFIG['CFBundleIconFiles'][0]}"}],
                    'metadata' => {'bundle-identifier' => CONFIG['CFBundleIdentifier'],
                                   'bundle-version' => CONFIG['CFBundleVersion'],
                                   'kind' => 'software',
                                   'title' => APPNAME}]}
  file = File.new(PLIST_FILE, 'w')
  file.write data.to_plist
  file.close
end

IPA_FILE = "#{DIR}/#{APPNAME}.ipa"
file IPA_FILE => :ipa_files do
  puts "building IPA for application #{APPNAME}"
  archive = "/usr/bin/xcrun -sdk iphoneos PackageApplication build/Release-iphoneos/#{APPNAME}.app -o #{File.expand_path(IPA_FILE)} --embed #{PROVPROFILE_PATH} $LOG_FILTER_PIPE"
  sh archive
end

multitask :generate_files => [JSON_FILE, PLIST_FILE, IPA_FILE]

desc("Create tarball suitable for deployment")
task :package  => :generate_files do
  puts "PACKAGE application #{APPNAME}"
  copy "#{APPNAME}/iTunesArtwork.jpg", DIR
  CONFIG['CFBundleIconFiles'].each {|icon| copy "#{icon}", DIR}
  users = File.new("#{DIR}/users.txt", 'w')
  users.write CONFIG['users'].gsub(',', "\n")
  users.close
end

desc("Deploy on '#{CONFIG['server']}'")
task :deploy => [:clean, :build, :package] do
  keys = CONFIG['ssh_path']
  sh "chmod 600 #{keys}"
  host = "#{CONFIG['user']}@#{SERVER}"
  www_path = CONFIG['www_path']
  sh "SoftwareFactory/publish.bash #{APPNAME} #{CONFIG['CFBundleVersion']} #{host} #{www_path} #{keys}"
end

