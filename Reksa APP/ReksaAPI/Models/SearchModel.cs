using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace ReksaAPI.Models
{
    public class SearchModel
    {
        public class Agen
        {
            public string AgentCode { get; set; }
            public string AgentDesc { get; set; }
            public int AgentId { get; set; }
        }
        public class Bank
        {
            public string BankCode { get; set; }
            public string BankDesc { get; set; }
            public int BankId { get; set; }
        }
        public class Booking
        {
            public string RefID { get; set; }
            public DateTime TanggalTransaksi { get; set; }
            public string BookingId { get; set; }
        }
        public class City
        {
            public string CityName{ get; set; }
        }
        public class Client
        {
            public int ClientId { get; set; }
            public string ClientCode { get; set; }
            public string ClientName { get; set; }
            public string CIFNo { get; set; }
        }
        public class Customer
        {
            public string CIFNo { get; set; }
            public string CIFName { get; set; }
            public int NasabahId { get; set; }
        }
        public class Currency
        {
            public string CurrencyCode { get; set; }
            public string CurrencyName { get; set; }
        }
        public class Office
        {
            public int Id { get; set; }
            public string OfficeId { get; set; }
            public string OfficeName { get; set; }
        }
        public class Product
        {
            public string ProdCode { get; set; }
            public string ProdName { get; set; }
            public int ProdId { get; set; }
        }
        public class Referentor
        {
            public string EMPLID { get; set; }
            public string NAME { get; set; }
        }
        public class Switching
        {
            public string RefID { get; set; }
            public string TanggalTransaksi { get; set; }
            public string TranId { get; set; }
        }
        public class TransaksiClientNew
        {
            public string ClientCode { get; set; }
            public string ClientId  { get; set; }
            public string CIFNo { get; set; }
            public DateTime JoinDate { get; set; }
            public bool IsEmployee { get; set; }
            public bool IsRDB { get; set; }
        }
        public class TransaksiProduct
        {
            public string ProdCode { get; set; }
            public string ProdName { get; set; }
            public string ProdId { get; set; }
            public string ProdCCY { get; set; }
        }
        public class TransaksiRefID
        {
            public string RefID { get; set; }
            public System.DateTime TanggalTransaksi { get; set; }
        }
        public class Waperd
        {
            public int employee_id { get; set; }
            public string WaperdNo { get; set; }
            public System.DateTime DateExpire { get; set; }
        }

    }
}
