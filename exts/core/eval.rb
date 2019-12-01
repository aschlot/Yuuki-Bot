module YuukiBot
  cmds = []

  cmds << self.gencommand(:eval) do |event,args|
    return if event.user.id != 228574821590499329
    begin
        msg = event.respond "#{YuukiBot.config['emoji_loading']} Evaluating..."
        init_time = Time.now
        result = eval args.join(' ')
        result = result.to_s
        if result.nil? || result == '' || result == ' ' || result == "\n"
          msg.edit "#{YuukiBot.config['emoji_tickbox']} Done! (No output)\nCommand took #{(Time.now - init_time)} seconds to execute!"
          next
        end
        str = ''
        if result.length >= 1984
          str << "#{YuukiBot.config['emoji_warning']} Your output exceeded the character limit! (`#{result.length - 1984}`/`1984`)"
          str << "You can view the result here: https://hastebin.com/raw/#{$uploader.upload_raw(result)}\nCommand took #{(Time.now - init_time)} seconds to execute!"
        else
          str << "Output: ```\n#{result}```Command took #{(Time.now - init_time)} seconds to execute!"
        end
        msg.edit(str)
        rescue Exception => e
        msg.edit("#{YuukiBot.config['emoji_error']} An error has occured!! ```ruby\n#{e}```\nCommand took #{(Time.now - init_time)} seconds to execute!")
      end
  end

  @bot.addext(Ext.new('core/say', cmds, 'core/ping.rb'))
end
