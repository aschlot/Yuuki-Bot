module YuukiBot
  cmds = []

  cmds << self.gencommand(:load) do |event,args|
    begin
      event.bot.load_ext(args.join(' '))
      event.respond "✅ Loaded extension `#{args.join(' ')}`"
    rescue Exception  => e
      event.respond "Nice job you fuckin broke it: ```ruby\n#{e}```"
    end
  end

  cmds << self.gencommand(:unload) do |event,args|
    begin
      event.bot.unload_ext(args.join(' '))
      event.respond "✅ Unloaded extension `#{args.join(' ')}`"
    rescue Exception  => e
      event.respond "Nice job you fuckin broke it: ```ruby\n#{e}```"
    end
  end

  cmds << self.gencommand(:reload) do |event,args|
    begin
      event.bot.reload_ext(args.join(' '))
      event.respond "✅ Reloaded extension `#{args.join(' ')}`"
    rescue Exception  => e
      event.respond "Nice job you fuckin broke it: ```ruby\n#{e}```"
    end
  end

  @bot.addext(Ext.new('core/load', cmds, 'core/ping.rb'))
end
