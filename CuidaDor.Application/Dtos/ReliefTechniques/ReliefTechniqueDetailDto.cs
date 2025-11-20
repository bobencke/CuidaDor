using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CuidaDor.Application.Dtos.ReliefTechniques
{
    public class ReliefTechniqueDetailDto : ReliefTechniqueListItemDto
    {
        public List<TechniqueStepDto> Steps { get; set; } = new();
    }
}
