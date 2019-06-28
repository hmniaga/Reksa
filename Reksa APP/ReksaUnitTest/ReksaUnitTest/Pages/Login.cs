using OpenQA.Selenium;
using System;
using System.Collections.Generic;
using System.Text;

namespace ReksaUnitTest.Pages
{
    class Login
    {
        private IWebDriver _driver;
        public Login(IWebDriver driver)
        {
            _driver = driver;
        }

        public IWebElement txtUserName => _driver.FindElement(By.Id("Username"));
        public IWebElement txtPassword => _driver.FindElement(By.Id("Password"));
        public IWebElement btnLogin => _driver.FindElement(By.Id("btnLogin"));

        public void PerformLogin(string username, string password)
        {
            txtUserName.SendKeys(username);
            txtPassword.SendKeys(password);
            btnLogin.Submit();
        }
    }
}
