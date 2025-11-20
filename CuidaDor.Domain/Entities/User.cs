using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CuidaDor.Domain.Entities
{
    public class User
    {
        public int Id { get; set; }

        public string Email { get; set; } = string.Empty;

        public string FullName { get; set; } = string.Empty;

        public int? Age { get; set; }

        public string Sex { get; set; } = string.Empty;

        public string PhoneNumber { get; set; } = string.Empty;

        public string PasswordHash { get; set; } = string.Empty;

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        public AccessibilityPreference? AccessibilityPreference { get; set; }

        public ConsentLgpd? ConsentLgpd { get; set; }

        public ICollection<UserComorbidity> Comorbidities { get; set; } = new List<UserComorbidity>();

        public ICollection<PainAssessment> PainAssessments { get; set; } = new List<PainAssessment>();

        public ICollection<TechniqueSession> TechniqueSessions { get; set; } = new List<TechniqueSession>();

        public ICollection<GeneralFeedback> GeneralFeedbacks { get; set; } = new List<GeneralFeedback>();
    }
}
