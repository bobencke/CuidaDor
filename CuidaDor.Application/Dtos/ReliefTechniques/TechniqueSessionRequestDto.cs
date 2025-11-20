using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CuidaDor.Application.Dtos.ReliefTechniques
{
    public class TechniqueSessionRequestDto
    {
        public int ReliefTechniqueId { get; set; }
        public DateTime StartedAt { get; set; }
        public DateTime FinishedAt { get; set; }
        public int ResultFeeling { get; set; }
        public string? Notes { get; set; }
    }
}
