module YuukiBot

  class Ext
    attr_reader :name, :cmds, :path

    def initialize(name, cmds, path)
      @name = name
      @cmds = cmds
      @path = path
    end

    def inject(bot)
      bot.exts[@name] = {path: @path, cmds:[]}
      cmds.each {|cmd|
        bot.exts[@name][:cmds].push(cmd.name)
        bot.commands[cmd.name] = cmd
      }
    end

  end
end