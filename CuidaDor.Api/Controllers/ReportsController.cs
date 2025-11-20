using System.Security.Claims;
using CuidaDor.Application.Dtos.Reports;
using CuidaDor.Application.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.IdentityModel.Tokens.Jwt;

namespace CuidaDor.Api.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class ReportsController : ControllerBase
    {
        private readonly IReportService _reportService;

        public ReportsController(IReportService reportService)
        {
            _reportService = reportService;
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

        [HttpGet("pain")]
        public async Task<ActionResult<PainReportDto>> GetPainReport([FromQuery] int days = 7)
        {
            var userId = GetUserId();
            var result = await _reportService.GetPainReportAsync(userId, days);
            return Ok(result);
        }
    }
}
