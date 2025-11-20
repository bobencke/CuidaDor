using CuidaDor.Application.Dtos.Feedback;
using CuidaDor.Application.Interfaces;
using CuidaDor.Domain.Entities;
using CuidaDor.Domain.Enums;
using CuidaDor.Infrastructure.Persistence;

namespace CuidaDor.Application.Services
{
    public class FeedbackService : IFeedbackService
    {
        private readonly CuidaDorDbContext _context;

        public FeedbackService(CuidaDorDbContext context)
        {
            _context = context;
        }

        public async Task AddFeedbackAsync(int userId, GeneralFeedbackRequestDto dto)
        {
            var entity = new GeneralFeedback
            {
                UserId = userId,
                CreatedAt = DateTime.UtcNow,
                Text = dto.Text,
                GeneralFeeling = dto.GeneralFeeling.HasValue
                    ? (FaceScaleAfterPractice?)dto.GeneralFeeling.Value
                    : null
            };

            _context.GeneralFeedbacks.Add(entity);
            await _context.SaveChangesAsync();
        }
    }
}
