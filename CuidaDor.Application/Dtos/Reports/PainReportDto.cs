using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CuidaDor.Application.Dtos.Reports
{
    public class PainReportDto
    {
        public List<PainEvolutionPointDto> Evolution { get; set; } = new();
        public double? PercentageReduction { get; set; }
    }
}
