using Microsoft.VisualStudio.TestTools.UnitTesting;
using OpenQA.Selenium;
using OpenQA.Selenium.Chrome;
using System;
using ReksaUnitTest.Pages;
using System.IO;
using System.Reflection;

namespace ReksaUnitTest
{
    [TestClass]
    public class ReksaUnitTest
    {
        [TestMethod]
        public void InquiryTransaksi()
        {
            IWebDriver driver = new ChromeDriver(Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location));
            driver.Manage().Window.Maximize();
            driver.Navigate().GoToUrl("https://reksatrial3.azurewebsites.net");
            
            Login loginPage = new Login(driver);
            loginPage.PerformLogin("usertest02", "B@ndung123");

            Transaksi trxPage = new Transaksi(driver);
            trxPage.PerformTransaksi();

            Console.WriteLine("Test Completed!!");

        }
    }
}
