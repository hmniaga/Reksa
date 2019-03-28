using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Reksa.Models
{
    public class OtorisasiModel
    {
        public class Detail
        {
            public bool CheckB { get; set; }
            public string TranId { get; set; }
            public string TranCode { get; set; }
            public string ValueDate { get; set; }
            public string ClientCode { get; set; }
            public string CIFName { get; set; }
            public string FullAmount { get; set; }
            public string ProdCode { get; set; }
            public string AgentCode { get; set; }
        }

        public class MainTranksasi
        {
            public bool CheckB { get; set; }
            public string TranId { get; set; }
            public string TranCode { get; set; }
            public string ValueDate { get; set; }
            public string ClientCode { get; set; }
            public string CIFName { get; set; }
            public string FullAmount { get; set; }
            public string ProdCode { get; set; }
            public string AgentCode { get; set; }
            public string TranDesc { get; set; }
            public string TranCCY { get; set; }
            public string TranAmt { get; set; }
            public string TranUnit { get; set; }
            public string SubcFee { get; set; }
            public string RedempFee { get; set; }
        }
        public class MainProduct
        {
            public bool CheckB { get; set; }
            public string ProdId { get; set; }
            public string ProdCode { get; set; }
            public string ProdName { get; set; }
            public string ProdCCY { get; set; }
            public string TypeName { get; set; }
            public string ManInvName { get; set; }
            public string NAV { get; set; }
            public string EffectiveAfter { get; set; }
        }
        public class AuthParamGlobal
        {
            public bool CheckB { get; set; }
            public string TipeAction { get; set; }
            public string Id { get; set; }
            public string ProdId { get; set; }
            public string ProductCode { get; set; }
            public string Kode { get; set; }
            public string Deskripsi { get; set; }
            public string Desc2 { get; set; }
            public string Desc5 { get; set; }
            public System.DateTime TglEfektif { get; set; }
            public System.DateTime TglExpire { get; set; }
            public string Keterangan { get; set; }
            public string MinSwitchRedempt { get; set; }
            public string JenisSwitchRedempt { get; set; }
            public string SwitchingFeeNonKaryawan { get; set; }
            public string SwitchingFeeKaryawan { get; set; }
            public string OfficeId { get; set; }
            public System.DateTime TanggalValuta { get; set; }
            public System.DateTime LastUpdate { get; set; }
            public string LastUser { get; set; }
        }

    }
}
