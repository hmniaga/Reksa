using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Reksa.Models
{
    public class NavigationModel
    {
        public string MenuId { get; set; }
        public string ModuleName { get; set; }
        public string MenuName { get; set; }
        public string MenuCaption { get; set; }
        public string ParentMenu { get; set; }
        public string MenuToolTip { get; set; }
        public string AccessId { get; set; }
        public string IsApproval { get; set; }
        public string MenuKey { get; set; }
        public string SiloId { get; set; }
        public string MenuGroupId { get; set; }
        public string IsEOD { get; set; }
        public string Controller { get; set; }
        public string Action { get; set; }
        public string icon { get; set; }
    }
}
