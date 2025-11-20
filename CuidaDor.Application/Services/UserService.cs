using CuidaDor.Application.Dtos.Users;
using CuidaDor.Application.Interfaces;
using CuidaDor.Domain.Entities;
using CuidaDor.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;

namespace CuidaDor.Application.Services
{
    public class UserService : IUserService
    {
        private readonly CuidaDorDbContext _context;

        public UserService(CuidaDorDbContext context)
        {
            _context = context;
        }

        public async Task<UserProfileDto> GetProfileAsync(int userId)
        {
            var user = await _context.Users
                .Include(u => u.Comorbidities)
                .Include(u => u.AccessibilityPreference)
                .Include(u => u.ConsentLgpd)
                .FirstAsync(u => u.Id == userId);

            return new UserProfileDto
            {
                Id = user.Id,
                FullName = user.FullName,
                Age = user.Age,
                Sex = user.Sex,
                PhoneNumber = user.PhoneNumber,
                Email = user.Email,
                Comorbidities = user.Comorbidities.Select(c => c.Name).ToList(),
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
        }

        public async Task<UserProfileDto> UpdateProfileAsync(int userId, UpdateUserProfileRequestDto dto)
        {
            var user = await _context.Users
                .Include(u => u.Comorbidities)
                .Include(u => u.AccessibilityPreference)
                .Include(u => u.ConsentLgpd)
                .FirstAsync(u => u.Id == userId);

            user.FullName = dto.FullName;
            user.Age = dto.Age;
            user.Sex = dto.Sex;
            user.PhoneNumber = dto.PhoneNumber;

            // Comorbidades
            _context.UserComorbidities.RemoveRange(user.Comorbidities);
            user.Comorbidities = dto.Comorbidities
                .Select(c => new UserComorbidity { UserId = user.Id, Name = c })
                .ToList();

            // Acessibilidade
            if (user.AccessibilityPreference == null)
            {
                user.AccessibilityPreference = new AccessibilityPreference
                {
                    UserId = user.Id
                };
            }
            user.AccessibilityPreference.FontScale = dto.Accessibility.FontScale;
            user.AccessibilityPreference.HighContrast = dto.Accessibility.HighContrast;
            user.AccessibilityPreference.VoiceReading = dto.Accessibility.VoiceReading;

            // LGPD
            if (dto.AcceptLgpd)
            {
                if (user.ConsentLgpd == null)
                {
                    user.ConsentLgpd = new ConsentLgpd
                    {
                        UserId = user.Id,
                        Accepted = true,
                        AcceptedAt = DateTime.UtcNow,
                        PolicyVersion = "v1"
                    };
                }
                else
                {
                    user.ConsentLgpd.Accepted = true;
                    user.ConsentLgpd.AcceptedAt = DateTime.UtcNow;
                }
            }

            await _context.SaveChangesAsync();

            return await GetProfileAsync(userId);
        }
    }
}
