using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CuidaDor.Application.Dtos.Reports
{
    public class ReliefTechniqueExportDto
    {
        public int Id { get; set; }
        public string Name { get; set; } = default!;
        public string? ShortDescription { get; set; }
        public string? WarningText { get; set; }
    }
}
