using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Reksa.Models
{
    public interface IMenuMasterService
    {
        IEnumerable<NavigationModel> GetMenuMaster();
        IEnumerable<NavigationModel> GetMenuMaster(String UserRole);
    }
}
