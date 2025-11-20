using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CuidaDor.Domain.Entities
{
    public class TechniqueStep
    {
        public int Id { get; set; }
        public int ReliefTechniqueId { get; set; }

        public int Order { get; set; }
        public string Description { get; set; } = null!;

        public ReliefTechnique ReliefTechnique { get; set; } = null!;
    }
}
