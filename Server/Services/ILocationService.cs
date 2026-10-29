using Server.DTOs;

namespace Server.Services
{
    public interface ILocationService
    {
        Task<SharedLocationDto> ShareLocationAsync(
            int userId,
            string userName,
            string userRole,
            ShareLocationRequestDto dto);

        Task<SharedLocationDto?> UpdateLiveLocationAsync(
            int userId,
            UpdateLiveLocationDto dto);

        Task<bool> StopLiveLocationAsync(
            int userId,
            string? shareCode = null);

        Task<UserLocationDashboardDto> GetUserDashboardAsync(
            int userId,
            double? currentLat = null,
            double? currentLng = null);

        Task<SharedLocationDto?> GetSharedLocationByCodeAsync(string shareCode);

        Task<bool> DeleteSharedLocationAsync(int userId, string id);
    }
}

