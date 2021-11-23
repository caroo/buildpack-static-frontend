require 'yaml'

class Seo
  def initialize(path_to_urls)
    @yaml = YAML.load_file(path_to_urls)
  end

  def paths
    @paths ||= @yaml.keys.map do |path_part|
      "/fahrzeuge/#{path_part}"
    end
  end

  def urls
    paths.map do |path|
      host + path
    end
  end

  def host
    @host ||= if !(env_host = ENV["HOST"]).nil?
                env_host
              elsif !(appname = ENV['HEROKU_APP_NAME']).nil?
                "https://#{appname}.herokuapp.com"
              else
                ''
              end
  end

  def context
    binding
  end
end
