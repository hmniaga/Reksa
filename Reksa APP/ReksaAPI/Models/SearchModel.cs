using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
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
        public class BankCode
        {
            public string KodeBank { get; set; }
            public string NamaBank { get; set; }
            public string Branch { get; set; }
            public string Alamat { get; set; }
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
            public string ProdCCY { get; set; }
            public string TypeCode { get; set; }
            public string ManInvCode { get; set; }
            public string CustodyCode { get; set; }
            public decimal NAV { get; set; }
            public decimal MinTotalUnit { get; set; }
            public decimal MaxTotalUnit { get; set; }
            public decimal MaxDailyUnit { get; set; }
            public decimal MaxDailyNom { get; set; }
            public long MaxDailyCust { get; set; }
            public DateTime PeriodStart { get; set; }
            public DateTime PeriodEnd { get; set; }
            public DateTime MatureDate { get; set; }
            public DateTime ChangeDate { get; set; }
            public DateTime ValueDate { get; set; }
            public long MaxMinUnit { get; set; }
            public int CloseEndBit { get; set; }
            public bool IsDeviden { get; set; }
            public int DevidenPeriod { get; set; }
            public long SubcFeeBased { get; set; }
            public long RedempFeeBased { get; set; }
            public long MaintenanceFee { get; set; }
            public string MIAccountId { get; set; }
            public string CTDAccountId { get; set; }
            public string CalcCode { get; set; }
            public int Status { get; set; }
            public int UpFrontFee { get; set; }
            public int SellingFee { get; set; }
            public string DevidentPct { get; set; }
            public int EffectiveAfter { get; set; }
            public string NFSFundCode { get; set; }
        }
        public class Referentor
        {
            public string EMPLID { get; set; }
            public string NAME { get; set; }
        }
        public class Switching
        {
            public string RefID { get; set; }
            public System.DateTime TanggalTransaksi { get; set; }
            public string TranId { get; set; }
        }
        public class TransaksiClientNew
        {
            public string ClientCode { get; set; }
            public string ClientName { get; set; }
            public string ClientId  { get; set; }
            public string CIFNo { get; set; }
            public DateTime JoinDate { get; set; }
            public bool IsEmployee { get; set; }
            public string IsRDB { get; set; }
        }
        public class ClientSwitchIn
        {
            public string ClientCode { get; set; }
            public string ClientName { get; set; }
            public string ClientId { get; set; }
            public string CIFNo { get; set; }
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
            [DisplayFormat(ApplyFormatInEditMode = true, DataFormatString = "{0:dd/MM/yyyy}")]
            public DateTime TanggalTransaksi { get; set; }
        }
        public class Waperd
        {
            public int employee_id { get; set; }
            public string WaperdNo { get; set; }
            public System.DateTime DateExpire { get; set; }
        }
        public class FrekuensiDebet
        {
            public int FrekuensiPendebetan { get; set; }
        }
        public class TypeReksadana
        {
            public string TypeCode { get; set; }
            public string TypeName { get; set; }
            public int TypeId { get; set; }
        }
        public class ManInvestasi
        {
            public string ManInvCode { get; set; }
            public string ManInvName { get; set; }
            public int ManInvId { get; set; }
        }
        public class Custody
        {
            public string CustodyCode { get; set; }
            public string CustodyName { get; set; }
            public int CustodyId { get; set; }
        }
        public class CalcDevident
        {
            public string CalcCode { get; set; }
            public string CalcName { get; set; }
            public int CalcId { get; set; }
        }
    }
}
