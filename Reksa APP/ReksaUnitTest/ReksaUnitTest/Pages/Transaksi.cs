using OpenQA.Selenium;
using System;
using System.Collections.Generic;
using System.Text;

namespace ReksaUnitTest.Pages
{
    class Transaksi
    {
        private IWebDriver _driver;
        public Transaksi(IWebDriver driver)
        {
            _driver = driver;
        }
        
        public IWebElement menu => _driver.FindElement(By.Id("navbarDropdownTransaksi"));
        public IWebElement parentmenu => _driver.FindElement(By.Id("menuTransaksi"));
        public IWebElement btnRefresh => _driver.FindElement(By.Id("btnRefresh"));

        public void PerformTransaksi()
        {
            menu.Click();
            parentmenu.Click();
        }
    }
}
