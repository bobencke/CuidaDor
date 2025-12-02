using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CuidaDor.Application.Dtos.Reports
{
    public class PainAssessmentExportDto
    {
        public int Id { get; set; }
        public int UserId { get; set; }

        public DateTime Date { get; set; }

        public int UsualPain { get; set; }
        public int LocalizedPain { get; set; }
        public int MoodToday { get; set; }
        public int SleepQuality { get; set; }

        public bool LimitsPhysicalActivities { get; set; }
        public bool PainWorseWithMovement { get; set; }
        public bool UsesPainMedication { get; set; }
        public bool UsesNonDrugPainRelief { get; set; }

        public string? Notes { get; set; }
    }
}
