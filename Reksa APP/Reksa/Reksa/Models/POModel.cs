﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Reksa.Models
{
    public class POModel
    {
    }
    public class MaintRejectBooking
    {
        public int BookingId { get; set; }
        public int KodeProduk { get; set; }
        public string NamaProduk { get; set; }
        public string BookingCode { get; set; }
        public string NamaNasabah { get; set; }
        public decimal NominalBooking { get; set; }
        public DateTime TanggalBooking { get; set; }
        public string RekeningRelasi { get; set; }
        public string NamaRekeningRelasi { get; set; }
        public string AgentCode { get; set; }
        public string NIKSeller { get; set; }
        public string NamaSeller { get; set; }
        public int intNIK { get; set; }
    }
    public class MaintCancelTransaksi
    {
        public int TranId { get; set; }
        public int KodeProduk { get; set; }
        public string NamaProduk { get; set; }
        public string ClientCode { get; set; }
        public string NamaNasabah { get; set; }
        public decimal NominalSubscription { get; set; }
        public DateTime ValueDate { get; set; }
        public string RekeningRelasi { get; set; }
        public string NamaRekeningRelasi { get; set; }
        public string AgentCode { get; set; }
        public string NIKSeller { get; set; }
        public string NamaSeller { get; set; }
        public int intNIK { get; set; }
    }
    public class RecalculateMFeeView
    {
        public string TanggalTransaksi { get; set; }
        public string ReverseTanggalTransaksi { get; set; }
        public string ClientCode { get; set; }
        public decimal OutstandingUnit { get; set; }
        public decimal NAV { get; set; }
    }
    public class RecalculateMFee
    {
        public int ProdId { get; set; }
        public int BankCustody { get; set; }
        public List<RecalculateMFeeView> listPreview { get; set; }
    }
    public class ImportDataMFee
    {
        public string FileName { get; set; }
        public int ProdId { get; set; }
        public int BankCustody { get; set; }
        public int isRecalculate { get; set; }
        public List<ImportDataMFeeView> listPreview { get; set; }
    }
    public class ImportDataMFeeView
    {
        public string ClientCode { get; set; }
        public int ClientId { get; set; }
        public decimal NAV { get; set; }
        public string NAVDate { get; set; }
        public string NominalMaintenanceFee { get; set; }
        public string OutstandingDate { get; set; }
        public string OutstandingUnit { get; set; }
        public int PembagiHariMFee { get; set; }
        public int ProdId { get; set; }
        public string ProductCode { get; set; }
        public string Remark { get; set; }
        public string ReverseTanggalTransaksi { get; set; }
        public string TanggalTransaksi { get; set; }        
    }
    public class PreviewMaintFee
    {
        public string StartDate { get; set; }
        public string EndDate { get; set; }
        public List<PreviewMaintFeeView> listPreview { get; set; }
    }
    public class PreviewMaintFeeView
    {
        public bool CheckB { get; set; }
        public int ProdId { get; set; }
        public string ProdCode { get; set; }
        public string ProdName { get; set; }
        public string CustodyCode { get; set; }
    }
    public class MaintCancelTransaksiIBMB
    {
        public string TranCode { get; set; }
        public int TranType { get; set; }
        public int NIK { get; set; }
    }
    public class ImportData
    {
        public int Type { get; set; }
        public int BankCustody { get; set; }
        public int Period { get; set; }
        public string FileName { get; set; }
        public int NIK { get; set; }
        public string TableNames { get; set; }
        public List<SinkronisasiTransaksi> listTransaksi { get; set; }
        public List<OSUnitShareholderID> listOSUnitShareholderID { get; set; }
        public List<OSUnitClientCode> listOSUnitClientCode { get; set; }
    }
    public class SinkronisasiTransaksi {
        public DateTime TglTransaksi { get; set; }
        public DateTime TglNAV { get; set; }
        public string JenisTransaksi { get; set; }
        public string Produk { get; set; }
        public string ClientCode { get; set; }
        public string ClientName { get; set; }
        public string AgentCode { get; set; }
        public decimal Unit { get; set; }
        public decimal NAV { get; set; }
        public decimal Nominal { get; set; }
        public decimal UnitBalance { get; set; }
        public DateTime TglGoodFund { get; set; }
        public string ShareholderID { get; set; }
        public int TransID { get; set; }
    }
    public class OSUnitShareholderID {
        public DateTime TglEOD { get; set; }
        public string ShareholderID { get; set; }
        public decimal EndingBalance { get; set; }
        public string ProductCode { get; set; }
        public int TranId { get; set; }
    }
    public class OSUnitClientCode
    {
        public DateTime TglEOD { get; set; }
        public string ClientCode { get; set; }
        public decimal EndingBalance { get; set; }
        public string ProductCode { get; set; }
    }
}
