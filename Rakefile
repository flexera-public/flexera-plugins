require 'rubygems'
require 'json'
require 'fileutils'
require_relative 'tools/lib/helper'
helper = Helper.new

# the list of policies is consumed by the tools/plugin_sync/plugin_sync.pt
# and the docs.rightscale.com build to generate the policies/user/policy_list.html
# the file is uploaded to S3 during a merge to master deploy step in .travis.yml
desc "Create a list of active plugins to be published to the Public Plugin Catalog"
task :generate_plugin_list do
  FileUtils.mkdir_p 'dist'
  file_list = []
  # get a list of the plugins and exlude certain directories
  Dir['**/*.rb','**/*.plugin'].reject{ |f|  f['tools/'] || f['libraries/'] || f['bundle']}.sort.each do |file|
    change_log = ::File.join(file.split('/')[0...-1].join('/'),'CHANGELOG.md')
    readme = ::File.join(file.split('/')[0...-1].join('/'),'README.md')
    publish = true

    if !file.match(/test_code/)
      if File.readlines(file, "r:bom|utf-8").grep(/type\W+(?:'|")plugin(?:'|")/).empty?
        puts "Skipping non plugin file #{file}"
        next
      end
      cmd = "./tools/bin/compile #{file}"
      plugin  = `#{cmd}`
      json = {}

      if helper.valid_json?(plugin)
        json = JSON.parse(plugin)
      else
        puts "File syntax check failed. #{file}."
        puts plugin
      end

      if json["type"] && json["type"]=='plugin' && json["info"]
        name = json["plugins"].keys[0]
        version = json["plugins"][json["plugins"].keys[0]]["version"]
        #version = helper.nested_hash_value(json["plugins"],"version")
        provider = json["info"]["provider"]
        service = json["info"]["service"]
        publish = json["info"]["publish"]
        short_description = json["short_description"]
        # not all plugins have the publish key
        # set these to true,
        if publish.nil? || publish=='true' || publish==true
          publish = true
        else
          publish = false
        end

        # skip plugin if the version isn't supplied or if version is '0.0'
        if  ! publish
          puts "Skipping #{name}, plugin not published"
          next
        end

        puts "Adding #{name} #{file} #{version}"

        file_list<<{
          "name": name,
          "file_name": file,
          "version": version,
          "change_log": change_log,
          "description": short_description,
          "readme": readme,
          "provider": provider,
          "service": service,
        }
      end
    end
  end
  plugins = {"plugins": file_list }
  File.open('dist/active-plugin-list.json', 'w') { |file| file.write(JSON.pretty_generate(plugins)+"\n") }
end
