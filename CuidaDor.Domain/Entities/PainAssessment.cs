
using CuidaDor.Domain.Enums;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CuidaDor.Domain.Entities
{

    public class PainAssessment
    {
        public int Id { get; set; }
        public int UserId { get; set; }

        public DateTime Date { get; set; }

        public PainScale UsualPain { get; set; }
        public FaceScale LocalizedPain { get; set; }
        public FaceScale MoodToday { get; set; }
        public FaceScale SleepQuality { get; set; }

        public bool LimitsPhysicalActivities { get; set; }
        public bool PainWorseWithMovement { get; set; }
        public bool UsesPainMedication { get; set; }
        public bool UsesNonDrugPainRelief { get; set; }

        public string? Notes { get; set; }

        public User User { get; set; } = null!;
    }
}
