using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Web;

namespace Reksa.Models
{
    [Serializable()]
    public class UserDetailModel
    {
        public string NIK { get; set; }
        public string Username { get; set; }
        public string Classification { get; set; }
        public string Branch { get; set; }
        public string EmployeeName { get; set; }
        public string Jabatan { get; set; }
        public int NIKAtasan { get; set; }
        public int UserGroupId { get; set; }
        public int SegmentId { get; set; }
        public string Segment { get; set; }
        public string SegmentDesc { get; set; }
        public string GroupName { get; set; }
        public string Role { get; set; }
        public string RoleDesc { get; set; }
        public string Division { get; set; }
    }
}