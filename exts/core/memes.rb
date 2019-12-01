module YuukiBot
    cmds = []
  
    cmds << self.gencommand(:say) do |event,args|
      message = args.join(' ')
      new_msg = event.respond(Helper.filter_everyone(message))
    end
  
    @bot.addext(Ext.new('core/say', cmds, 'core/ping.rb'))
  end
  