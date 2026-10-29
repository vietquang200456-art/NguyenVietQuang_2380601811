namespace Server.DTOs
{
    public class ShareLocationRequestDto
    {
        public double Latitude { get; set; }
        public double Longitude { get; set; }
        public double AccuracyMeters { get; set; } = 5.0;
        public double AltitudeMeters { get; set; } = 0.0;
        public double SpeedMps { get; set; } = 0.0;
        public double BearingDegrees { get; set; } = 0.0;
        public string Provider { get; set; } = "GPS_SATELLITE";
        public string Address { get; set; } = string.Empty;
        public string? Ward { get; set; }
        public string? District { get; set; }
        public string? City { get; set; }
        public string? PlusCode { get; set; }
        public string ShareType { get; set; } = "current"; // current, live, pickup, sos, safe_point
        public string RecipientTarget { get; set; } = "Gia đình"; // Gia đình, Bé Minh An, Bé Bông Nhi, Hỗ trợ kỹ thuật
        public string? Note { get; set; }
        public bool IsLive { get; set; } = false;
        public int DurationMinutes { get; set; } = 30;
        public int BatteryLevel { get; set; } = 100;
    }

    public class UpdateLiveLocationDto
    {
        public string ShareCode { get; set; } = string.Empty;
        public double Latitude { get; set; }
        public double Longitude { get; set; }
        public double AccuracyMeters { get; set; } = 5.0;
        public double AltitudeMeters { get; set; } = 0.0;
        public double SpeedMps { get; set; } = 0.0;
        public double BearingDegrees { get; set; } = 0.0;
        public string Provider { get; set; } = "GPS_SATELLITE";
        public string? Address { get; set; }
        public int BatteryLevel { get; set; } = 100;
    }

    public class SharedLocationDto
    {
        public string Id { get; set; } = string.Empty;
        public string ShareCode { get; set; } = string.Empty;
        public int UserId { get; set; }
        public string UserName { get; set; } = string.Empty;
        public string UserRole { get; set; } = "User";
        public double Latitude { get; set; }
        public double Longitude { get; set; }
        public double AccuracyMeters { get; set; }
        public double AltitudeMeters { get; set; }
        public double SpeedMps { get; set; }
        public double BearingDegrees { get; set; }
        public string Provider { get; set; } = "GPS_SATELLITE";
        public string Address { get; set; } = string.Empty;
        public string? Ward { get; set; }
        public string? District { get; set; }
        public string? City { get; set; }
        public string PlusCode { get; set; } = string.Empty;
        public string DmsCoordinates { get; set; } = string.Empty;
        public string GoogleMapsUrl { get; set; } = string.Empty;
        public string ShareType { get; set; } = "current";
        public string RecipientTarget { get; set; } = "Gia đình";
        public string Note { get; set; } = string.Empty;
        public bool IsLive { get; set; }
        public bool IsActive { get; set; }
        public int BatteryLevel { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime UpdatedAt { get; set; }
        public DateTime? ExpiresAt { get; set; }
    }

    public class KidDeviceLocationDto
    {
        public string KidId { get; set; } = string.Empty;
        public string KidName { get; set; } = string.Empty;
        public string DeviceName { get; set; } = string.Empty;
        public double Latitude { get; set; }
        public double Longitude { get; set; }
        public double AccuracyMeters { get; set; }
        public string Address { get; set; } = string.Empty;
        public string SafeZoneName { get; set; } = string.Empty;
        public int SafeRadiusMeters { get; set; }
        public bool IsInSafeZone { get; set; }
        public int BatteryPercent { get; set; }
        public double? DistanceFromUserMeters { get; set; }
        public string? BearingFromUserText { get; set; }
        public DateTime UpdatedAt { get; set; }
    }

    public class UserLocationDashboardDto
    {
        public SharedLocationDto? ActiveLiveShare { get; set; }
        public List<SharedLocationDto> RecentShares { get; set; } = new();
        public List<KidDeviceLocationDto> KidLocations { get; set; } = new();
    }
}

