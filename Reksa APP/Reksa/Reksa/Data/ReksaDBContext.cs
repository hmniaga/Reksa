using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Reksa.Models;

namespace Reksa.Data
{
    public partial class ReksaDBContext : DbContext
    {
        public ReksaDBContext(DbContextOptions<ReksaDBContext> options)
            : base(options)
        {
            var connectionString = this.Database.GetDbConnection().ConnectionString;
        }
    }
}
