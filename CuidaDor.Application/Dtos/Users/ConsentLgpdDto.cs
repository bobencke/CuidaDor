using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CuidaDor.Application.Dtos.Users
{
    public class ConsentLgpdDto
    {
        public bool Accepted { get; set; }

        public DateTime? AcceptedAt { get; set; }

        [MaxLength(50)]
        public string PolicyVersion { get; set; } = "1.0";
    }
}
