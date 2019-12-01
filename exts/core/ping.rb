module YuukiBot
  cmds = []

  cmds << self.gencommand(:ping, invokers: %w(ping pong peng pung pyng pang 🅱ing)) do |event,_|
    return_message = event.respond("<a:istyping:393844856973426709> | #{event.user.mention}, Calculating ping...")
    ping = (return_message.id - event.message.id) >> 22
    choose = %w(i o e u y a)
    return_message.edit("🏓 | #{event.user.mention}, p#{choose.sample}ng! (`#{ping}ms`)")
  end

  @bot.addext(Ext.new('core/ping', cmds, 'core/ping.rb'))
end
