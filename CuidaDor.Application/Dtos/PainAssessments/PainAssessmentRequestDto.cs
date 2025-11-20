using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CuidaDor.Application.Dtos.PainAssessments
{
    public class PainAssessmentRequestDto
    {
        [Range(1, 5)]
        public int UsualPain { get; set; }

        [Range(1, 5)]
        public int LocalizedPain { get; set; }

        [Range(1, 5)]
        public int MoodToday { get; set; }

        [Range(1, 5)]
        public int SleepQuality { get; set; }

        public bool LimitsPhysicalActivities { get; set; }

        public bool PainWorseWithMovement { get; set; }

        public bool UsesPainMedication { get; set; }

        public bool UsesNonDrugPainRelief { get; set; }

        [MaxLength(1000)]
        public string? Notes { get; set; }
    }
}
