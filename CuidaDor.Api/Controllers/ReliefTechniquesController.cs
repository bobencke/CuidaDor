using System.Security.Claims;
using CuidaDor.Application.Dtos.ReliefTechniques;
using CuidaDor.Application.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.IdentityModel.Tokens.Jwt;

namespace CuidaDor.Api.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class ReliefTechniquesController : ControllerBase
    {
        private readonly IReliefTechniqueService _service;

        public ReliefTechniquesController(IReliefTechniqueService service)
        {
            _service = service;
        }

        private int GetUserId()
        {
            var userIdClaim =
                User.FindFirst(JwtRegisteredClaimNames.Sub) ??
                User.FindFirst(ClaimTypes.NameIdentifier);

            if (userIdClaim == null)
                throw new UnauthorizedAccessException("Usuário não identificado no token.");

            return int.Parse(userIdClaim.Value);
        }

        [HttpGet]
        [AllowAnonymous]
        public async Task<ActionResult<IEnumerable<ReliefTechniqueListItemDto>>> GetAll()
        {
            var result = await _service.GetAllAsync();
            return Ok(result);
        }

        [HttpGet("{id:int}")]
        public async Task<ActionResult<ReliefTechniqueDetailDto>> GetById(int id)
        {
            var result = await _service.GetByIdAsync(id);
            if (result == null) return NotFound();
            return Ok(result);
        }

        [HttpPost("sessions")]
        public async Task<IActionResult> AddSession(TechniqueSessionRequestDto dto)
        {
            var userId = GetUserId();
            await _service.AddSessionAsync(userId, dto);
            return Ok();
        }
    }
}
