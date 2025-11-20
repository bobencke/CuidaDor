using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CuidaDor.Application.Dtos.Users
{
    public class UserProfileDto
    {
        public int Id { get; set; }
        public string FullName { get; set; } = null!;
        public int? Age { get; set; }
        public string? Sex { get; set; }
        public string? PhoneNumber { get; set; }
        public string Email { get; set; } = null!;

        public List<string> Comorbidities { get; set; } = new();
        public AccessibilityPreferenceDto? Accessibility { get; set; }
        public ConsentLgpdDto? Consent { get; set; }
    }
}
