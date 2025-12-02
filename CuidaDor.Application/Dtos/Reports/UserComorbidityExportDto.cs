using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CuidaDor.Application.Dtos.Reports
{
    public class UserComorbidityExportDto
    {
        public int Id { get; set; }
        public int UserId { get; set; }
        public string Name { get; set; } = default!;
    }
}
