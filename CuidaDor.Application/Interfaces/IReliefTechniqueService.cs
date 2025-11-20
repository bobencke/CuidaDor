using CuidaDor.Application.Dtos.ReliefTechniques;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CuidaDor.Application.Interfaces
{
    public interface IReliefTechniqueService
    {
        Task<IEnumerable<ReliefTechniqueListItemDto>> GetAllAsync();
        Task<ReliefTechniqueDetailDto?> GetByIdAsync(int id);
        Task AddSessionAsync(int userId, TechniqueSessionRequestDto dto);
    }
}
