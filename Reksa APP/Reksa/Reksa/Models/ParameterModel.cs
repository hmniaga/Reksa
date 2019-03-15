using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System.ComponentModel.DataAnnotations;

namespace Reksa.Models
{
    public class ParameterModel
    {
        public int Id { get; set; }
        public string Kode { get; set; }
        public string Deskripsi { get; set; }
        public int ProdId { get; set; }
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
    public class MaintainParamGlobal
    {
        public int _intType { get; set; }
        public string _strTreeInterface { get; set; }
        public string txtbSP1 { get; set; }
        public string txtbSP2 { get; set; }
        public string txtbSP3 { get; set; }
        public string txtbSP4 { get; set; }
        public string txtbSP5 { get; set; }
        public string textBox1 { get; set; }
        public bool checkBox1 { get; set; }
        public System.DateTime dtpSP { get; set; }
        public System.DateTime dtpSP5 { get; set; }
        public string cmpsrSearch1 { get; set; }
        public string cmpsrSearch2 { get; set; }
        public string comboBox1 { get; set; }
        public string comboBox3 { get; set; }
        public string textPctSwc { get; set; }
        public System.DateTime TanggalValuta { get; set; }
        public int Id { get; set; }
    }
}
