using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CuidaDor.Application.Dtos.Auth
{
    public class RegisterRequestDto
    {
        [Required]
        [MaxLength(200)]
        public string FullName { get; set; } = string.Empty;

        [Range(0, 120)]
        public int Age { get; set; }

        [Required]
        [MaxLength(50)]
        public string Sex { get; set; } = string.Empty; // Feminino/Masculino/Outro

        [Required]
        [MaxLength(20)]
        public string PhoneNumber { get; set; } = string.Empty;

        [Required]
        [EmailAddress]
        [MaxLength(200)]
        public string Email { get; set; } = string.Empty;

        [Required]
        [MinLength(6)]
        public string Password { get; set; } = string.Empty;

        // Comorbidades
        public List<string> Comorbidities { get; set; } = new();

        // Acessibilidade
        [Range(0.5, 2.0)]
        public double FontScale { get; set; } = 1.0;
        public bool HighContrast { get; set; }
        public bool VoiceReading { get; set; }

        // LGPD
        public bool ConsentLgpd { get; set; }
    }
}
