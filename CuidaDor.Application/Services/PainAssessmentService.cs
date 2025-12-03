using CuidaDor.Application.Dtos.PainAssessments;
using CuidaDor.Application.Interfaces;
using CuidaDor.Domain.Entities;
using CuidaDor.Domain.Enums;
using CuidaDor.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;

namespace CuidaDor.Application.Services
{
    public class PainAssessmentService : IPainAssessmentService
    {
        private readonly CuidaDorDbContext _context;

        public PainAssessmentService(CuidaDorDbContext context)
        {
            _context = context;
        }

        public async Task<PainAssessmentResponseDto> CreateAsync(int userId, PainAssessmentRequestDto dto)
        {
            var today = DateTime.Now.Date;

            var existsToday = await _context.PainAssessments
                .AsNoTracking()
                .AnyAsync(p =>
                    p.UserId == userId &&
                    p.Date.Date == today);

            if (existsToday)
            {
                throw new InvalidOperationException(
                    "Você já registrou sua avaliação de dor hoje.");
            }

            var entity = new PainAssessment
            {
                UserId = userId,
                Date = DateTime.Now,
                UsualPain = (PainScale)dto.UsualPain,
                LocalizedPain = (FaceScale)dto.LocalizedPain,
                MoodToday = (FaceScale)dto.MoodToday,
                SleepQuality = (FaceScale)dto.SleepQuality,
                LimitsPhysicalActivities = dto.LimitsPhysicalActivities,
                PainWorseWithMovement = dto.PainWorseWithMovement,
                UsesPainMedication = dto.UsesPainMedication,
                UsesNonDrugPainRelief = dto.UsesNonDrugPainRelief,
                Notes = dto.Notes
            };

            _context.PainAssessments.Add(entity);
            await _context.SaveChangesAsync();

            return new PainAssessmentResponseDto
            {
                Id = entity.Id,
                Date = entity.Date,
                UsualPain = (int)entity.UsualPain,
                LocalizedPain = (int)entity.LocalizedPain,
                MoodToday = (int)entity.MoodToday,
                SleepQuality = (int)entity.SleepQuality
            };
        }

        public async Task<IEnumerable<PainAssessmentResponseDto>> GetByPeriodAsync(int userId, DateTime? from, DateTime? to)
        {
            var query = _context.PainAssessments
                .Where(p => p.UserId == userId);

            if (from.HasValue)
                query = query.Where(p => p.Date >= from.Value);
            if (to.HasValue)
                query = query.Where(p => p.Date <= to.Value);

            var list = await query
                .OrderBy(p => p.Date)
                .ToListAsync();

            return list.Select(p => new PainAssessmentResponseDto
            {
                Id = p.Id,
                Date = p.Date,
                UsualPain = (int)p.UsualPain,
                LocalizedPain = (int)p.LocalizedPain,
                MoodToday = (int)p.MoodToday,
                SleepQuality = (int)p.SleepQuality
            });
        }
    }
}
