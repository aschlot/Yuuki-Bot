using System;
using System.Threading.Tasks;
using DSharpPlus;
using DSharpPlus.CommandsNext;

namespace Yuuki_Bot {
    class Program {
        static DiscordClient discord;
        static CommandsNextModule commands;
        static Random rnd = new Random();

        static void Main(string[] args) {
            MainAsync(args).ConfigureAwait(false).GetAwaiter().GetResult();
        }

        static async Task MainAsync(string[] args) {
            discord = new DiscordClient(new DiscordConfiguration {
                Token = // TODO: Add configuration,
                TokenType = TokenType.Bot,
                UseInternalLogHandler = true,
                LogLevel = LogLevel.Debug
            });

            commands = discord.UseCommandsNext(new CommandsNextConfiguration {
                StringPrefix = // TODO: add configuration
            });

            await discord.ConnectAsync();
            await Task.Delay(-1);
        }
}
