# frozen_string_literal: true

namespace :ci do
  namespace :license_finder do
    desc 'Run compliance task and generates the license report if complies'
    task :run do
      if Rake::Task['ci:license_finder:compliance'].invoke
        Bundler.clean_system(bundle_gemfile_env, "rake ci:license_finder:report > #{Rails.root.join('doc/licenses/licenses.xml')}")
      end
    end
    desc 'Check license compliance of dependencies'
    task :compliance do
      STDOUT.puts 'Checking license compliance'
      unless Bundler.clean_system(bundle_gemfile_env, 'lib/threescale_license_finder/bin/threescale_license_finder')
        STDERR.puts "*** License compliance test failed  ***"
        exit 1
      end
    end
    desc 'Generates a report with the dependencies and their licenses'
    task :report do
      Bundler.clean_system(bundle_gemfile_env, 'lib/threescale_license_finder/bin/threescale_license_finder report --format=xml')
    end

    def bundle_gemfile_env
      {'BUNDLE_GEMFILE' => 'Gemfile'}
    end
  end
end
