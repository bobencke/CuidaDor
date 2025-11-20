using CuidaDor.Domain.Enums;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CuidaDor.Domain.Entities
{
    public class GeneralFeedback
    {
        public int Id { get; set; }
        public int UserId { get; set; }

        public DateTime CreatedAt { get; set; }
        public string? Text { get; set; }
        public FaceScaleAfterPractice? GeneralFeeling { get; set; }

        public User User { get; set; } = null!;
    }
}
