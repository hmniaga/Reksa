using Microsoft.AspNetCore.Mvc;

namespace Reksa.Controllers
{ 
    public class AuthenticationController : Controller
    {
        public ActionResult Login()
        {
            return View("Login");
        }
    }
}
