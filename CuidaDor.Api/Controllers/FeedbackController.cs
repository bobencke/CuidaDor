using System.Security.Claims;
using CuidaDor.Application.Dtos.Feedback;
using CuidaDor.Application.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.IdentityModel.Tokens.Jwt;

namespace CuidaDor.Api.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class FeedbackController : ControllerBase
    {
        private readonly IFeedbackService _service;

        public FeedbackController(IFeedbackService service)
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
        public async Task<IActionResult> Create(GeneralFeedbackRequestDto dto)
        {
            var userId = GetUserId();
            await _service.AddFeedbackAsync(userId, dto);
            return Ok();
        }
    }
}
