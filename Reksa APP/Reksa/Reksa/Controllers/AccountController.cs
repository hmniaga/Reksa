using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using Reksa.Data.Entities;
using Reksa.ViewModels;
using System.Linq;
using System.Threading.Tasks;

namespace Reksa.Controllers
{
    public class AccountController : Controller
    {
        private readonly ILogger<AccountController> _logger;
        private readonly SignInManager<ApplicationUser> _signInManager;
        public AccountController(ILogger<AccountController> logger, SignInManager<ApplicationUser> signInManager)
        //public AccountController(ILogger<AccountController> logger)
        {
            _logger = logger;
            _signInManager = signInManager;
        }
        public IActionResult Login()
        {
           // if (this.User.Identity.IsAuthenticated)
            //{
                //return RedirectToAction("Index", "Home");
            //}
            return View();
        }
        [HttpPost]
        public async Task<IActionResult> Login(LoginViewModel model)
        {
            if (ModelState.IsValid)
            {
                var result = await _signInManager.PasswordSignInAsync(model.Username, model.Password, model.RememberMe, false);
                if (result.Succeeded)
                {
                    if (Request.Query.Keys.Contains("ReturnUrl"))
                    {
                        Redirect(Request.Query["ReturnUrl"].First());
                    }
                    else
                    {
                        RedirectToAction("Index", "Home");
                    }
                }
            }

            ModelState.AddModelError("", "Failed to login");
            return View();
        }

     
    }
}
