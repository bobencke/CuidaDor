using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CuidaDor.Domain.Entities
{
    public class AccessibilityPreference
    {
        public int Id { get; set; }

        public int UserId { get; set; }
        public User User { get; set; } = default!;

        public double FontScale { get; set; } = 1.0;

        public bool HighContrast { get; set; }

        public bool VoiceReading { get; set; }
    }
}
