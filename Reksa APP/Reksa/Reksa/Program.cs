using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore;
using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;

namespace Reksa
{
    public class Program
    {
        public static void Main(string[] args)
        {
            BuildWebHost(args).Run();
        }

        //public static IWebHost BuildWebHost(string[] args) =>
        //    WebHost.CreateDefaultBuilder(args)
        //        .UseStartup<Startup>()
        //        .Build();
        public static IWebHost BuildWebHost(string[] args)
        {
            var configuration = new ConfigurationBuilder().AddCommandLine(args).Build();

            return WebHost.CreateDefaultBuilder(args)
                .UseConfiguration(configuration)
                .UseStartup<Startup>()
                .UseKestrel(options => 
                {
                    options.AddServerHeader = false;
                })
                .Build();
        }
    }
}