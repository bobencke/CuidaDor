using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CuidaDor.Application.Dtos.ReliefTechniques
{
    public class ReliefTechniqueListItemDto
    {
        public int Id { get; set; }
        public string Name { get; set; } = null!;
        public string ShortDescription { get; set; } = null!;
        public string? WarningText { get; set; }
    }
}
