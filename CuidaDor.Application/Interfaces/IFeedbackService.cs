using CuidaDor.Application.Dtos.Feedback;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CuidaDor.Application.Interfaces
{
    public interface IFeedbackService
    {
        Task AddFeedbackAsync(int userId, GeneralFeedbackRequestDto dto);
    }
}
