using CuidaDor.Application.Dtos.Reports;
using CuidaDor.Application.Interfaces;
using CuidaDor.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;

namespace CuidaDor.Application.Services
{
    public class ReportService : IReportService
    {
        private readonly CuidaDorDbContext _context;

        public ReportService(CuidaDorDbContext context)
        {
            _context = context;
        }

        public async Task<PainReportDto> GetPainReportAsync(int userId, int days)
        {
            var from = DateTime.UtcNow.Date.AddDays(-days);

            var data = await _context.PainAssessments
                .Where(p => p.UserId == userId && p.Date >= from)
                .OrderBy(p => p.Date)
                .ToListAsync();

            var evolution = data
                .GroupBy(p => p.Date.Date)
                .Select(g => new PainEvolutionPointDto
                {
                    Date = g.Key,
                    AveragePain = g.Average(p => (int)p.UsualPain)
                })
                .OrderBy(e => e.Date)
                .ToList();

            double? percentage = null;
            if (evolution.Count >= 2)
            {
                var first = evolution.First().AveragePain;
                var last = evolution.Last().AveragePain;
                if (first > 0)
                    percentage = ((first - last) / first) * 100.0;
            }

            return new PainReportDto
            {
                Evolution = evolution,
                PercentageReduction = percentage
            };
        }
    }
}
