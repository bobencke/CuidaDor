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

        Task<UserDataExportDto> GetUserDataExportAsync(
            int userId,
            CancellationToken cancellationToken = default
        );

        Task<List<UserDataExportDto>> GetAllUsersDataExportAsync(
            CancellationToken cancellationToken = default
        );


    }
}
