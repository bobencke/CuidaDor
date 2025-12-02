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

        [HttpGet("export")]
        public async Task<ActionResult<UserDataExportDto>> Export(CancellationToken cancellationToken)
        {
            var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;

            if (string.IsNullOrWhiteSpace(userIdClaim))
            {
                return Unauthorized("User id claim not found.");
            }

            if (!int.TryParse(userIdClaim, out var userId))
            {
                return Unauthorized("Invalid user id claim.");
            }

            var export = await _reportService.GetUserDataExportAsync(userId, cancellationToken);
            return Ok(export);
        }

        [HttpGet("export/all")]
        public async Task<ActionResult<List<UserDataExportDto>>> ExportAll(
            CancellationToken cancellationToken)
        {
            var exports = await _reportService.GetAllUsersDataExportAsync(cancellationToken);
            return Ok(exports);
        }

    }
}
