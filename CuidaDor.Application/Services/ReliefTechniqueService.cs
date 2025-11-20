using CuidaDor.Application.Dtos.ReliefTechniques;
using CuidaDor.Application.Interfaces;
using CuidaDor.Domain.Entities;
using CuidaDor.Domain.Enums;
using CuidaDor.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;

namespace CuidaDor.Application.Services
{
    public class ReliefTechniqueService : IReliefTechniqueService
    {
        private readonly CuidaDorDbContext _context;

        public ReliefTechniqueService(CuidaDorDbContext context)
        {
            _context = context;
        }

        public async Task<IEnumerable<ReliefTechniqueListItemDto>> GetAllAsync()
        {
            var list = await _context.ReliefTechniques.AsNoTracking().ToListAsync();

            return list.Select(t => new ReliefTechniqueListItemDto
            {
                Id = t.Id,
                Name = t.Name,
                ShortDescription = t.ShortDescription,
                WarningText = t.WarningText
            });
        }

        public async Task<ReliefTechniqueDetailDto?> GetByIdAsync(int id)
        {
            var tech = await _context.ReliefTechniques
                .Include(t => t.Steps)
                .FirstOrDefaultAsync(t => t.Id == id);

            if (tech == null) return null;

            return new ReliefTechniqueDetailDto
            {
                Id = tech.Id,
                Name = tech.Name,
                ShortDescription = tech.ShortDescription,
                WarningText = tech.WarningText,
                Steps = tech.Steps
                    .OrderBy(s => s.Order)
                    .Select(s => new TechniqueStepDto { Order = s.Order, Description = s.Description })
                    .ToList()
            };
        }

        public async Task AddSessionAsync(int userId, TechniqueSessionRequestDto dto)
        {
            var session = new TechniqueSession
            {
                UserId = userId,
                ReliefTechniqueId = dto.ReliefTechniqueId,
                StartedAt = dto.StartedAt,
                FinishedAt = dto.FinishedAt,
                ResultFeeling = (FaceScaleAfterPractice)dto.ResultFeeling,
                Notes = dto.Notes
            };

            _context.TechniqueSessions.Add(session);
            await _context.SaveChangesAsync();
        }
    }
}
