using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CuidaDor.Application.Dtos.Users
{
    public class UpdateUserProfileRequestDto
    {
        public string FullName { get; set; } = null!;
        public int? Age { get; set; }
        public string? Sex { get; set; }
        public string? PhoneNumber { get; set; }
        public List<string> Comorbidities { get; set; } = new();
        public AccessibilityPreferenceDto Accessibility { get; set; } = new();
        public bool AcceptLgpd { get; set; }
    }
}
