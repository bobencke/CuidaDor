using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using CuidaDor.Application.Dtos.Auth;
using CuidaDor.Application.Interfaces;
using CuidaDor.Domain.Entities;
using CuidaDor.Infrastructure.Persistence;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.IdentityModel.Tokens;

namespace CuidaDor.Application.Services
{
    public class AuthService : IAuthService
    {
        private readonly CuidaDorDbContext _context;
        private readonly IConfiguration _configuration;
        private readonly PasswordHasher<User> _passwordHasher = new();

        public AuthService(CuidaDorDbContext context, IConfiguration configuration)
        {
            _context = context;
            _configuration = configuration;
        }

        public async Task<AuthResponseDto> RegisterAsync(RegisterRequestDto dto)
        {
            // se quiser: obrigar a aceitar LGPD
            if (!dto.ConsentLgpd)
                throw new InvalidOperationException("É necessário aceitar a política de privacidade (LGPD).");

            if (await _context.Users.AnyAsync(u => u.Email == dto.Email))
                throw new InvalidOperationException("E-mail já cadastrado.");

            // 1. Usuário
            var user = new User
            {
                Email = dto.Email,
                FullName = dto.FullName,
                Age = dto.Age,
                Sex = dto.Sex,
                PhoneNumber = dto.PhoneNumber,
                CreatedAt = DateTime.UtcNow
            };

            user.PasswordHash = _passwordHasher.HashPassword(user, dto.Password);

            _context.Users.Add(user);
            await _context.SaveChangesAsync(); // para gerar Id

            // 2. Preferências de acessibilidade
            var pref = new AccessibilityPreference
            {
                UserId = user.Id,
                FontScale = dto.FontScale,
                HighContrast = dto.HighContrast,
                VoiceReading = dto.VoiceReading
            };
            _context.AccessibilityPreferences.Add(pref);

            // 3. Consentimento LGPD
            var consent = new ConsentLgpd
            {
                UserId = user.Id,
                Accepted = dto.ConsentLgpd,
                AcceptedAt = dto.ConsentLgpd ? DateTime.UtcNow : null,
                PolicyVersion = "1.0"
            };
            _context.ConsentLgpds.Add(consent);

            // 4. Comorbidades
            if (dto.Comorbidities != null)
            {
                foreach (var c in dto.Comorbidities)
                {
                    if (string.IsNullOrWhiteSpace(c)) continue;

                    _context.UserComorbidities.Add(new UserComorbidity
                    {
                        UserId = user.Id,
                        Name = c.Trim()
                    });
                }
            }

            await _context.SaveChangesAsync();

            // 5. JWT
            return GenerateToken(user);
        }

        public async Task<AuthResponseDto> LoginAsync(LoginRequestDto dto)
        {
            var user = await _context.Users
                .FirstOrDefaultAsync(u => u.Email == dto.Email);

            if (user == null)
                throw new InvalidOperationException("Credenciais inválidas.");

            var result = _passwordHasher.VerifyHashedPassword(
                user,
                user.PasswordHash,
                dto.Password
            );

            if (result == PasswordVerificationResult.Failed)
                throw new InvalidOperationException("Credenciais inválidas.");

            return GenerateToken(user);
        }

        private AuthResponseDto GenerateToken(User user)
        {
            var jwtSection = _configuration.GetSection("Jwt");
            var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwtSection["Key"]!));
            var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);

            var expiresMinutes = int.Parse(jwtSection["ExpiresMinutes"] ?? "60");

            var claims = new List<Claim>
            {
                new Claim(JwtRegisteredClaimNames.Sub, user.Id.ToString()),
                new Claim(ClaimTypes.NameIdentifier, user.Id.ToString()),
                new Claim(JwtRegisteredClaimNames.Email, user.Email),
                new Claim("name", user.FullName)
            };

            var tokenDescriptor = new SecurityTokenDescriptor
            {
                Subject = new ClaimsIdentity(claims),
                Expires = DateTime.UtcNow.AddMinutes(expiresMinutes),
                SigningCredentials = creds,
                Audience = jwtSection["Audience"],
                Issuer = jwtSection["Issuer"]
            };

            var tokenHandler = new JwtSecurityTokenHandler();
            var token = tokenHandler.CreateToken(tokenDescriptor);

            return new AuthResponseDto
            {
                Token = tokenHandler.WriteToken(token),
                ExpiresAt = tokenDescriptor.Expires ?? DateTime.UtcNow
            };
        }
    }
}
