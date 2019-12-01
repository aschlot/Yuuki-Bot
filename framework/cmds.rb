require 'discordrb'
module YuukiBot

  module Cmds

    class Prefix
      attr_reader :value
      attr_reader :type
      class TypeError < StandardError; end
      class DualError < TypeError; end
      def initialize(value, type)
        @value = value
        @type = type

        case @type
          when :prefix, :suffix
            raise TypeError, "Expected #{@type} to be a string." unless @value.is_a?(String)
          when :dual
            raise TypeError, "Expected #{@type} to be an array." unless @value.is_a?(Array)
            raise DualError, "Expected value array of a #{@type} to have two elements." unless @value.count == 2
          when :regex
            raise TypeError, "Expected #{@type} to be a Regexp." unless @value.is_a?(Regexp)
          else
            raise TypeError, "#{@type} is not a recognised prefix type."
        end

      end

      # https://github.com/ry00001/commandorobo/blob/6488f968566f75512f808452a640631144dc85eb/lib/commandorobo.rb#L46
      def parse(text)
        return nil unless self.check(text)
        case @type
          when :prefix
            return text[@value.length..text.length]
          when :suffix
            return text[0..-@value.length-1]
          when :dual
            return text[@value[0].length..-@value[1].length-1]
          when :regex
            return @value.match(text)
          else
            raise TypeError, "#{@type} is not a recognised prefix type!"
        end
      end

      # https://github.com/ry00001/commandorobo/blob/6488f968566f75512f808452a640631144dc85eb/lib/commandorobo.rb#L59
      def check(text)
        case @type
          when :prefix
            return text.start_with? @value
          when :suffix
            return text.end_with? @value
          when :dual
            return text.start_with?(@value[0]) && text.end_with?(@value[1])
          when :regex
            return !self.match(text).nil?
          else
            raise TypeError, "#{@type} is not a recognised prefix type!"
        end
      end

    end

    # Inspiration from https://github.com/ry00001/commandorobo/blob/6488f968566f75512f808452a640631144dc85eb/lib/commandorobo.rb#L88
    class Command
      attr_reader :name, :code, :permissions, :description, :invokers, :owner_only
      def initialize(name, code, permissions, description, invokers, bot)
        @name = name
        @code = code
        @permissions = permissions
        @desc = description
        @invokers = invokers.nil? ? [name.to_s] : invokers
        @bot = bot
      end

      def invoke(event, args)
        @code.call(event, args)
      end

    end

    class Bot < Discordrb::Bot
      attr_accessor :db, :exts, :commands
      def initialize(prefixes:nil, db:nil, ready: nil, parse_bots:false, **kwargs)
        super(**kwargs)
        @db = db
        @commands = {}
        @global_prefixes = prefixes
        @parse_bots = parse_bots
        @exts = {}

        # TODO
        @global_prefixes.map!{|prfx| Prefix.new(prfx, :prefix)}

        unless ready.nil?
          self.ready do |event|
            ready.call(event)
          end
        end

        self.message do |event|

          prefix = self.capture(event.content)
          next if prefix.nil?
          next unless prefix.check(event.content)

          capture = prefix.parse(event.content)

          if capture.is_a?(MatchData)
            capture = capture[1].split(/ /)
          else
            capture = capture.split(/ /)
          end

          # this may need to be refined
          target = capture.first
          cmd = self.get_command(target)
          capture.shift

          cmd.invoke(event, capture)
          null
        end
      end

      def get_prefix(text)
        @prefixes.map {|a| a if a.check text}.reject(&:!).first # reject all false
      end

      def get_command(name)
        @commands.select {|n, cmd| cmd.invokers.include? name}.values[0]
      end

      def command(name, perms:[], desc:nil, invokers:nil, &block)
        invokers = [name.to_s] if invokers.nil?

        @commands[name] = Command.new(name, block, perms, desc, invokers, self)
      end

      # https://github.com/ry00001/commandorobo/blob/6488f968566f75512f808452a640631144dc85eb/lib/commandorobo.rb#L206
      def capture(text)
        @global_prefixes.map {|a| a if a.check text}.reject(&:!).first # reject all false
      end

      def addext(ext)
        ext.inject(self)
      end

      def load_ext(name)
        # oh dear lord this is a horrible way of doing this.
        # TODO ^

        load('exts/' + name + '.rb') # help me
        puts "Extension #{name} loaded!"
      end

      def unload_ext(name)
        @exts[name][:cmds].each{|cmd|
          @commands.delete(cmd) # RIP
        }
      end

      def reload_ext(name)
        unload_ext(name)
        load_ext(name)
      end
    end
  end
  
  def self.gencommand(name, perms:[], desc:nil, invokers:nil, &block)
    invokers = [name.to_s] if invokers.nil?

    Cmds::Command.new(name, block, perms, desc, invokers, self)
  end
end
