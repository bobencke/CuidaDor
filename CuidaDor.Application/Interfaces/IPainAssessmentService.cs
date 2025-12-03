using CuidaDor.Application.Dtos.PainAssessments;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CuidaDor.Application.Interfaces
{
    public interface IPainAssessmentService
    {
        Task<PainAssessmentResponseDto> CreateAsync(int userId, PainAssessmentRequestDto dto);
        Task<IEnumerable<PainAssessmentResponseDto>> GetByPeriodAsync(int userId, DateTime? from, DateTime? to);
    }
}