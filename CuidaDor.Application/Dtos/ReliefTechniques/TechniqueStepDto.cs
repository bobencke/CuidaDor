using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CuidaDor.Application.Dtos.ReliefTechniques
{
    public class TechniqueStepDto
    {
        public int Order { get; set; }
        public string Description { get; set; } = null!;
    }
}
