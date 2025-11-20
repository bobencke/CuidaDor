using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CuidaDor.Application.Dtos.Feedback
{
    public class GeneralFeedbackRequestDto
    {
        public int? GeneralFeeling { get; set; } // 1-3
        public string? Text { get; set; }
    }
}
