using System.Security.Claims;
using CuidaDor.Application.Dtos.PainAssessments;
using CuidaDor.Application.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.IdentityModel.Tokens.Jwt;

namespace CuidaDor.Api.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class PainAssessmentsController : ControllerBase
    {
        private readonly IPainAssessmentService _service;

        public PainAssessmentsController(IPainAssessmentService service)
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

        [HttpPost]
        public async Task<ActionResult<PainAssessmentResponseDto>> Create(PainAssessmentRequestDto dto)
        {
            var userId = GetUserId();

            try
            {
                var result = await _service.CreateAsync(userId, dto);
                return Ok(result);
            }
            catch (InvalidOperationException ex)
            {
                return BadRequest(ex.Message);
            }
        }

        [HttpGet]
        public async Task<ActionResult<IEnumerable<PainAssessmentResponseDto>>> GetByPeriod(
            [FromQuery] DateTime? from,
            [FromQuery] DateTime? to)
        {
            var userId = GetUserId();
            var result = await _service.GetByPeriodAsync(userId, from, to);
            return Ok(result);
        }
    }
}
