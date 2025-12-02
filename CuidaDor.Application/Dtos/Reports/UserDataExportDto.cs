using CuidaDor.Application.Dtos.Users;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CuidaDor.Application.Dtos.Reports
{
    /// <summary>
    /// Pacote completo de dados de um usuário para export (.csv, etc).
    /// </summary>
    public class UserDataExportDto
    {
        public UserProfileDto User { get; set; } = default!;
        public List<UserComorbidityExportDto> Comorbidities { get; set; } = new();
        public List<PainAssessmentExportDto> PainAssessments { get; set; } = new();
        public List<TechniqueSessionExportDto> TechniqueSessions { get; set; } = new();
        public List<GeneralFeedbackExportDto> GeneralFeedbacks { get; set; } = new();

        public List<ReliefTechniqueExportDto> ReliefTechniques { get; set; } = new();
        public List<TechniqueStepExportDto> TechniqueSteps { get; set; } = new();
    }
}
