using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace ReksaAPI.Models
{
    public class CustomerAktifitasModel
    {
        public class ClientList
        {
            public string Pilih { get; set; }
            public string ProdCode { get; set; }
            public string ProdName { get; set; }
            public string ClientId { get; set; }
            public string ClientCode { get; set; }
            public string NAV { get; set; }
            public string UnitBalance { get; set; }
            public string UnitNominal { get; set; }
            public string Flag { get; set; }
            public string CIFStatus { get; set; }
            public string RDBNonRDB { get; set; }
            public string FlagClientCodeTA { get; set; }
        }
        public class PopulateAktifitas
        {
            public System.DateTime TanggalTransaksi { get; set; }
            public string KeteranganTransaksi { get; set; }
            public decimal DebetNom { get; set; }
            public decimal KreditNom { get; set; }
            public decimal Fee { get; set; }
            public decimal SaldoNom { get; set; }
            public string NAV { get; set; }
            public string UnitTransaction { get; set; }
            public string UnitBalance { get; set; }
            public string ChannelTransaksi { get; set; }
            public string Operator { get; set; }
            public string Checker { get; set; }
        }
        public class ClientRDB
        {
            public int JangkaWaktu { get; set; }
            public DateTime JatuhTempo { get; set; }
            public bool AutoRedemption { get; set; }
            public bool Asuransi { get; set; }
            public int FrekPendebetan { get; set; }
            public int SisaJangkaWaktu { get; set; }
            public bool IsDoneDebet { get; set; }
        }
    }
}
