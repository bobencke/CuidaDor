using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CuidaDor.Application.Dtos.Users
{
    public class AccessibilityPreferenceDto
    {
        [Range(0.5, 2.0)]
        public double FontScale { get; set; } = 1.0;

        public bool HighContrast { get; set; }
        public bool VoiceReading { get; set; }
    }
}
