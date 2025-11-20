using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CuidaDor.Domain.Entities
{
    public class ReliefTechnique
    {
        public int Id { get; set; }

        public string Name { get; set; } = null!;
        public string ShortDescription { get; set; } = null!;
        public string? WarningText { get; set; }

        public ICollection<TechniqueStep> Steps { get; set; } = new List<TechniqueStep>();
        public ICollection<TechniqueSession> Sessions { get; set; } = new List<TechniqueSession>();
    }
}
