using Microsoft.AspNetCore.Authentication.Cookies;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.HttpOverrides;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.DependencyInjection.Extensions;
using Newtonsoft.Json.Serialization;
using Reksa.Data;
using Reksa.Data.Entities;
using Reksa.Models;
using Rotativa.AspNetCore;

namespace Reksa
{
    public class Startup
    {
        public Startup(IConfiguration configuration)
        {
            Configuration = configuration;
        }

        public IConfiguration Configuration { get; }

        // This method gets called by the runtime. Use this method to add services to the container.
        public void ConfigureServices(IServiceCollection services)
        {
            services
                .AddMvc(
                options =>
                {
                    //options.Filters.Add(new AutoValidateAntiforgeryTokenAttribute());
                    //options.Filters.Add(new RequireHttpsAttribute());
                }
                )
                .AddJsonOptions(options => options.SerializerSettings.ContractResolver = new DefaultContractResolver());

            services.TryAddSingleton<IHttpContextAccessor, HttpContextAccessor>();

            services.AddAuthentication(CookieAuthenticationDefaults.AuthenticationScheme)
                .AddCookie(options =>
                {
                    options.AccessDeniedPath = "/Account/Error403";
                    options.LoginPath = "/Account/Login";
                });

            services.AddAuthorization(options => options.AddPolicy("SPV", p => p.RequireAuthenticatedUser().RequireRole("SPV")));
            
            services.AddKendo();

            services.AddSession();
        }

        // This method gets called by the runtime. Use this method to configure the HTTP request pipeline.
        public void Configure(IApplicationBuilder app, IHostingEnvironment env)
        {
            if (env.IsDevelopment())
            {
                app.UseDeveloperExceptionPage();
                app.UseBrowserLink();
            }
            else
            {
                app.UseExceptionHandler("/Account/Error500");
            }

            app.UseForwardedHeaders(new ForwardedHeadersOptions
            {
                ForwardedHeaders = ForwardedHeaders.XForwardedFor | ForwardedHeaders.XForwardedProto
            });

            app.UseHsts(options => options.MaxAge(days:365).IncludeSubdomains());

            app.UseStaticFiles();

            app.UseXXssProtection(options => options.EnabledWithBlockMode());

            app.UseXContentTypeOptions();

            app.UseSession();

            app.UseAuthentication();

            app.UseMvc(routes =>
            {
                routes.MapRoute(
                    name: "default",
                    template: "{controller=Home}/{action=Index}/{id?}");
            });

            // Configure Kendo UI
            app.UseKendo(env);
            RotativaConfiguration.Setup(env);
        }
    }
}