using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CuidaDor.Application.Dtos.PainAssessments
{
    public class PainAssessmentResponseDto
    {
        public int Id { get; set; }
        public DateTime Date { get; set; }

        public int UsualPain { get; set; }
        public int LocalizedPain { get; set; }
        public int MoodToday { get; set; }
        public int SleepQuality { get; set; }
    }
}
