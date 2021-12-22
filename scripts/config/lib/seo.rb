require 'json'
require 'uri'
require 'net/http'
require 'yaml'

class Seo
  USER_AGENT = "cars counter checker for Sitemap and Prerender(https://github.com/caroo/buildpack-static-frontend)".freeze

  def initialize(path_to_urls)
    @yaml = YAML.load_file(path_to_urls)
  end

  def paths
    @paths ||= filter_urls(@yaml).keys.map do |path_part|
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

  def filter_urls(urls)
    api_url = ENV['API_URL']
    minimum_cars = (ENV['MINIMUM_CARS_FOR_SITEMAP'] || 10).to_i

    urls.select do |url, params|
      uri = URI("#{api_url}/api/v1/cars/search/count?#{params}")

      request = Net::HTTP::Get.new(uri)
      request["User-Agent"] = USER_AGENT

      response = Net::HTTP.start(uri.hostname, uri.port, :use_ssl => (uri.scheme == 'https')) {|http|
        http.request(request)
      }

      cars_count = JSON.parse(response.body)['total_count']
      result = cars_count >= minimum_cars
      puts "removing #{url} from sitemap(cars_count: #{cars_count})" unless result
      result
    end
  end

  def context
    binding
  end
end
