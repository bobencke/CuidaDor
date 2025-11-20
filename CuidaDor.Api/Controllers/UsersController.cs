using System.Security.Claims;
using CuidaDor.Application.Dtos.Users;
using CuidaDor.Application.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace CuidaDor.Api.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class UsersController : ControllerBase
    {
        private readonly IUserService _userService;

        public UsersController(IUserService userService)
        {
            _userService = userService;
        }

        private int GetUserId() => int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)
                                             ?? User.FindFirstValue(ClaimTypes.NameIdentifier) ??
                                             User.FindFirst("sub")!.Value);

        [HttpGet("me")]
        public async Task<ActionResult<UserProfileDto>> GetMe()
        {
            var userId = GetUserId();
            var result = await _userService.GetProfileAsync(userId);
            return Ok(result);
        }

        [HttpPut("me")]
        public async Task<ActionResult<UserProfileDto>> UpdateMe(UpdateUserProfileRequestDto dto)
        {
            var userId = GetUserId();
            var result = await _userService.UpdateProfileAsync(userId, dto);
            return Ok(result);
        }
    }
}
