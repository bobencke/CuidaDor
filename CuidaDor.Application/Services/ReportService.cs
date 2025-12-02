using CuidaDor.Application.Dtos.Reports;
using CuidaDor.Application.Interfaces;
using CuidaDor.Infrastructure.Persistence;
using CuidaDor.Application.Dtos.Users;
using CuidaDor.Application.Dtos.PainAssessments;
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

        public async Task<UserDataExportDto> GetUserDataExportAsync(
            int userId,
            CancellationToken cancellationToken = default)
        {
            var user = await _context.Users
                .AsNoTracking()
                .Include(u => u.AccessibilityPreference)
                .Include(u => u.ConsentLgpd)
                .Include(u => u.Comorbidities)
                .SingleAsync(u => u.Id == userId, cancellationToken);

            var userProfile = new UserProfileDto
            {
                Id = user.Id,
                FullName = user.FullName,
                Age = user.Age,
                Sex = user.Sex,
                PhoneNumber = user.PhoneNumber,
                Email = user.Email,
                Accessibility = user.AccessibilityPreference == null
                    ? null
                    : new AccessibilityPreferenceDto
                    {
                        FontScale = user.AccessibilityPreference.FontScale,
                        HighContrast = user.AccessibilityPreference.HighContrast,
                        VoiceReading = user.AccessibilityPreference.VoiceReading
                    },
                Consent = user.ConsentLgpd == null
                    ? null
                    : new ConsentLgpdDto
                    {
                        Accepted = user.ConsentLgpd.Accepted,
                        AcceptedAt = user.ConsentLgpd.AcceptedAt,
                        PolicyVersion = user.ConsentLgpd.PolicyVersion
                    }
            };

            var comorbidities = await _context.UserComorbidities
                .AsNoTracking()
                .Where(c => c.UserId == userId)
                .Select(c => new UserComorbidityExportDto
                {
                    Id = c.Id,
                    UserId = c.UserId,
                    Name = c.Name
                })
                .ToListAsync(cancellationToken);

            var painAssessments = await _context.PainAssessments
                .AsNoTracking()
                .Where(p => p.UserId == userId)
                .OrderBy(p => p.Date)
                .Select(p => new PainAssessmentExportDto
                {
                    Id = p.Id,
                    UserId = p.UserId,
                    Date = p.Date,

                    UsualPain = (int)p.UsualPain,
                    LocalizedPain = (int)p.LocalizedPain,
                    MoodToday = (int)p.MoodToday,
                    SleepQuality = (int)p.SleepQuality,

                    LimitsPhysicalActivities = p.LimitsPhysicalActivities,
                    PainWorseWithMovement = p.PainWorseWithMovement,
                    UsesPainMedication = p.UsesPainMedication,
                    UsesNonDrugPainRelief = p.UsesNonDrugPainRelief,

                    Notes = p.Notes
                })
                .ToListAsync(cancellationToken);

            var sessions = await _context.TechniqueSessions
                .AsNoTracking()
                .Where(s => s.UserId == userId)
                .OrderBy(s => s.StartedAt)
                .Select(s => new TechniqueSessionExportDto
                {
                    Id = s.Id,
                    UserId = s.UserId,
                    ReliefTechniqueId = s.ReliefTechniqueId,
                    StartedAt = s.StartedAt,
                    FinishedAt = s.FinishedAt,
                    ResultFeeling = (int)s.ResultFeeling,
                    Notes = s.Notes
                })
                .ToListAsync(cancellationToken);

            var feedbacks = await _context.GeneralFeedbacks
                .AsNoTracking()
                .Where(f => f.UserId == userId)
                .OrderBy(f => f.CreatedAt)
                .Select(f => new GeneralFeedbackExportDto
                {
                    Id = f.Id,
                    UserId = f.UserId,
                    CreatedAt = f.CreatedAt,
                    GeneralFeeling = (int?)f.GeneralFeeling,
                    Text = f.Text
                })
                .ToListAsync(cancellationToken);

            var reliefTechniques = await _context.ReliefTechniques
                .AsNoTracking()
                .OrderBy(t => t.Id)
                .Select(t => new ReliefTechniqueExportDto
                {
                    Id = t.Id,
                    Name = t.Name,
                    ShortDescription = t.ShortDescription,
                    WarningText = t.WarningText
                })
                .ToListAsync(cancellationToken);

            var steps = await _context.TechniqueSteps
                .AsNoTracking()
                .OrderBy(s => s.ReliefTechniqueId)
                .ThenBy(s => s.Order)
                .Select(s => new TechniqueStepExportDto
                {
                    Id = s.Id,
                    ReliefTechniqueId = s.ReliefTechniqueId,
                    Order = s.Order,
                    Description = s.Description
                })
                .ToListAsync(cancellationToken);

            var export = new UserDataExportDto
            {
                User = userProfile,
                Comorbidities = comorbidities,
                PainAssessments = painAssessments,
                TechniqueSessions = sessions,
                GeneralFeedbacks = feedbacks,
                ReliefTechniques = reliefTechniques,
                TechniqueSteps = steps
            };

            return export;
        }

        public async Task<List<UserDataExportDto>> GetAllUsersDataExportAsync(
    CancellationToken cancellationToken = default)
        {
            var userIds = await _context.Users
                .AsNoTracking()
                .Select(u => u.Id)
                .ToListAsync(cancellationToken);

            var result = new List<UserDataExportDto>(userIds.Count);

            foreach (var id in userIds)
            {
                var export = await GetUserDataExportAsync(id, cancellationToken);
                result.Add(export);
            }

            return result;
        }

    }
}
