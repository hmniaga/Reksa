using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Authentication.Cookies;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using Reksa.Data.Entities;
using Reksa.Models;
using Reksa.ViewModels;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Security.Claims;
using System.Threading.Tasks;

namespace Reksa.Controllers
{
    public class AccountController : Controller
    {
        private string _strAPIUrl;
        private IConfiguration _config;
        private readonly IHttpContextAccessor _httpContextAccessor;
        private IHostingEnvironment _hostingEnvironment;
        public AccountController(IConfiguration iconfig, IHttpContextAccessor httpContextAccessor, IHostingEnvironment hostingEnvironment)
        {
            _config = iconfig;
            _strAPIUrl = _config.GetValue<string>("APIServices:url");
            _httpContextAccessor = httpContextAccessor;
            _hostingEnvironment = hostingEnvironment;
        }
        public IActionResult Login()
        {
            return View();
        }
        public IActionResult RecoverPW()
        {
            return View();
        }
        [HttpPost]
        public async Task<IActionResult> Login(LoginViewModel model)
        {
            if (ModelState.IsValid)
            {
                bool Succeeded = false;
                if (model.Username == "usertest01" && model.Password == "B@ndung123")
                {
                    Succeeded = true;
                    var identity = new ClaimsIdentity(new[] 
                    {
                        new Claim(ClaimTypes.Name, model.Username),
                        new Claim(ClaimTypes.Role, "admin")
                    }
                    , CookieAuthenticationDefaults.AuthenticationScheme
                    );
                    var principal = new ClaimsPrincipal(identity);
                    await HttpContext.SignInAsync(CookieAuthenticationDefaults.AuthenticationScheme, principal);
                }
                if (model.Username == "usertest02" && model.Password == "B@ndung123")
                {
                    Succeeded = true;
                    var identity = new ClaimsIdentity(new[]
                    {
                        new Claim(ClaimTypes.Name, model.Username),
                        new Claim(ClaimTypes.Role, "SPV"),
                    }
                    , CookieAuthenticationDefaults.AuthenticationScheme
                    );
                    var principal = new ClaimsPrincipal(identity);
                    await HttpContext.SignInAsync(CookieAuthenticationDefaults.AuthenticationScheme, principal,
                        new AuthenticationProperties
                        {
                            ExpiresUtc = DateTime.UtcNow.AddMinutes(20),
                            IsPersistent = true,
                            AllowRefresh = true
                        });
                }               

                if (Succeeded)
                {
                    if (Request.Query.Keys.Contains("ReturnUrl"))
                    {
                        Redirect(Request.Query["ReturnUrl"].First());
                    }
                    else
                    {
                        return RedirectToAction("Index", "Home");
                        //return View("~/Views/Home/Index.cshtml"); 
                    }
                }
                else
                {
                    ModelState.AddModelError("", "Failed to login");
                }
            }
            return View();
        }

        public async Task<IActionResult> Logout()
        {
            await HttpContext.SignOutAsync(CookieAuthenticationDefaults.AuthenticationScheme);
            return RedirectToAction("Login", "Account");
        }

        public IActionResult Error400 ()
        {
            return View();
        }
        public IActionResult Error403()
        {
            return View();
        }
        public IActionResult Error404()
        {
            return View();
        }
        public IActionResult Error500()
        {
            return View();
        }
        public IActionResult Error503()
        {
            return View();
        }        
    }
}
