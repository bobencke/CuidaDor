using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CuidaDor.Application.Dtos.Reports
{
    public class TechniqueSessionExportDto
    {
        public int Id { get; set; }
        public int UserId { get; set; }
        public int ReliefTechniqueId { get; set; }

        public DateTime StartedAt { get; set; }
        public DateTime FinishedAt { get; set; }

        /// <summary>
        /// Valor do enum FaceScaleAfterPractice (ex: 1=Melhor, 2=Igual, 3=Pior).
        /// </summary>
        public int ResultFeeling { get; set; }

        public string? Notes { get; set; }
    }
}
