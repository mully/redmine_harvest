require 'harvest'

module RedmineHarvest
  def self.configure(options)
    @config ||= { :email      => options[:email],
                  :password   => options[:password],
                  :sub_domain => options[:domain] }
  end

  def self.client
    raise Exception.new("No credentials provided.") unless @config

    @client ||= Harvest(@config)
  end
end
