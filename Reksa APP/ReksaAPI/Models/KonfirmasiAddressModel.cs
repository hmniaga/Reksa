using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace ReksaAPI.Models
{
    public class KonfirmasiAddressModel
    {
        public string Pilih { get; set; }
        public string Sequence { get; set; }
        public string AddressLine1 { get; set; }
        public string Address { get; set; }
        public string AddressLine2 { get; set; }
        public string AddressLine3 { get; set; }
        public string AddressLine4 { get; set; }
        public string KodePos { get; set; }
        public string AlamatLuarNegeri { get; set; }
        public string Keterangan { get; set; }
        public string AlamatUtama { get; set; }
        public string KodeAlamat { get; set; }
        public string AlamatSID { get; set; }
        public string PeriodThere { get; set; }
        public string PeriodThereCode { get; set; }
        public string JenisAlamat { get; set; }
        public string StaySince { get; set; }
        public string Kelurahan { get; set; }
        public string Kecamatan { get; set; }
        public string Kota { get; set; }
        public string Provinsi { get; set; }
        public string LastUpdatedDate { get; set; }

    }
}
