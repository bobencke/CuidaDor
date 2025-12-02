using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CuidaDor.Application.Dtos.Reports
{
    public class TechniqueStepExportDto
    {
        public int Id { get; set; }
        public int ReliefTechniqueId { get; set; }
        public int Order { get; set; }
        public string Description { get; set; } = default!;
    }
}
