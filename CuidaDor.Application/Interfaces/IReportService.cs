using CuidaDor.Application.Dtos.Reports;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CuidaDor.Application.Interfaces
{
    public interface IReportService
    {
        Task<PainReportDto> GetPainReportAsync(int userId, int days);
    }
}
