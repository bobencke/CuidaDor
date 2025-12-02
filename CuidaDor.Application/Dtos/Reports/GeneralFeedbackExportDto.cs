using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CuidaDor.Application.Dtos.Reports
{
    public class GeneralFeedbackExportDto
    {
        public int Id { get; set; }
        public int UserId { get; set; }

        public DateTime CreatedAt { get; set; }
        public int? GeneralFeeling { get; set; }
        public string? Text { get; set; }
    }
}
