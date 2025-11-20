using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CuidaDor.Domain.Entities
{
    public class ConsentLgpd
    {
        public int Id { get; set; }

        public int UserId { get; set; }
        public User User { get; set; } = default!;

        public bool Accepted { get; set; }

        public DateTime? AcceptedAt { get; set; }

        public string PolicyVersion { get; set; } = "1.0";
    }
}
