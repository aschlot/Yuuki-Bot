module YuukiBot
  require 'easy_translate'
  require 'haste'
  require 'open-uri'
  require 'redis'
  require 'redis-namespace'
  require 'json'
  
  if ENV['COMMANDRB_PATH'].nil?
    require 'commandrb'
  else
    puts '[INFO] Loading commandrb from Environment location.'
    require_relative "#{ENV['COMMANDRB_PATH']}/lib/commandrb"
  end

  if ENV['DISCORDRB_PATH'].nil?
    require 'discordrb'
  else
    puts '[INFO] Loading discordrb from Environment location.'
    require_relative "#{ENV['DISCORDRB_PATH']}/lib/discordrb"
  end
  require_relative 'old_cmds/setup'
  require_relative 'old_cmds/version'

  require_relative 'framework/cmds'
  require_relative 'framework/exts'

  module_dirs = %w(helper) # owner logging misc mod utility)
  module_dirs.each {|dir|
    Dir["old_cmds/#{dir}/*.rb"].each { |r|
     require_relative r
     puts "Loaded: #{r}" if @config['verbose']
    }
  }

  # Load Extra Commands if enabled.

  # if YuukiBot.config['extra_commands']
  #   puts 'Loading: Extra commands...' if @config['verbose']
  #   Dir['old_cmds/extra/*.rb'].each { |r| require_relative r; puts "Loaded: #{r}" if @config['verbose'] }
  # end

  ORIG_REDIS = Redis.new(host: YuukiBot.config['redis_host'], port: YuukiBot.config['redis_port'])
  REDIS = Redis::Namespace.new(YuukiBot.config['redis_namespace'], :redis => ORIG_REDIS )

  @bot = YuukiBot::Cmds::Bot.new(
    prefixes: @config['prefixes'],
    db: REDIS, ready: @config['ready'],
    token: @config['token'],
    client_id: @config['client_id'],
    parse_self: @config['parse_self']
  )

  @bot.load_ext('core/load')

  puts '>> Initial loading succesful!! <<'
  exit(1001) if YuukiBot.config['pretend_run']
  $uploader =  Haste::Uploader.new
  if YuukiBot.config['use_pry']
    @bot.bot.run(true)
    require 'pry'
    binding.pry
  else
    puts 'Connecting to Discord....'
    @bot.run
  end
end
