using CuidaDor.Domain.Enums;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CuidaDor.Domain.Entities
{
    public class TechniqueSession
    {
        public int Id { get; set; }
        public int UserId { get; set; }
        public int ReliefTechniqueId { get; set; }

        public DateTime StartedAt { get; set; }
        public DateTime FinishedAt { get; set; }

        public FaceScaleAfterPractice ResultFeeling { get; set; }
        public string? Notes { get; set; }

        public User User { get; set; } = null!;
        public ReliefTechnique ReliefTechnique { get; set; } = null!;
    }

}
