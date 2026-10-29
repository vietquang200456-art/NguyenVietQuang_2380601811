namespace Server.DTOs
{
    public class DeviceDto
    {
        public int Id { get; set; }
        public string Name { get; set; } = string.Empty;
        public string? Description { get; set; }
        public string Category { get; set; } = string.Empty;
        public decimal Price { get; set; }
        public string? Brand { get; set; }
        public string? ModelNumber { get; set; }
        public string? ImageUrl { get; set; }
        public int StockQuantity { get; set; }
        public int MinAge { get; set; }
        public int MaxAge { get; set; }
        public bool IsAvailable { get; set; }
        public double AverageRating { get; set; }
        public int ReviewCount { get; set; }
        public DateTime CreatedAt { get; set; }
    }

    public class CreateDeviceDto
    {
        public string Name { get; set; } = string.Empty;
        public string? Description { get; set; }
        public string Category { get; set; } = string.Empty;
        public decimal Price { get; set; }
        public string? Brand { get; set; }
        public string? ModelNumber { get; set; }
        public string? ImageUrl { get; set; }
        public int StockQuantity { get; set; }
        public int MinAge { get; set; }
        public int MaxAge { get; set; }
    }

    public class UpdateDeviceDto
    {
        public string? Name { get; set; }
        public string? Description { get; set; }
        public string? Category { get; set; }
        public decimal? Price { get; set; }
        public string? Brand { get; set; }
        public string? ModelNumber { get; set; }
        public string? ImageUrl { get; set; }
        public int? StockQuantity { get; set; }
        public int? MinAge { get; set; }
        public int? MaxAge { get; set; }
        public bool? IsAvailable { get; set; }
    }
}
