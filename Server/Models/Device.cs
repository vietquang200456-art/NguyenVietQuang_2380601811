namespace Server.Models
{
    public class Device
    {
        public int Id { get; set; }
        public string Name { get; set; } = string.Empty;
        public string? Description { get; set; }
        public DeviceCategory Category { get; set; }
        public decimal Price { get; set; }
        public string? Brand { get; set; }
        public string? ModelNumber { get; set; }
        public string? ImageUrl { get; set; }
        public int StockQuantity { get; set; }
        public int MinAge { get; set; } // Độ tuổi tối thiểu
        public int MaxAge { get; set; } // Độ tuổi tối đa
        public bool IsAvailable { get; set; } = true;
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        public DateTime? UpdatedAt { get; set; }

        // Foreign key
        public int CreatedBy { get; set; }
        public User? Creator { get; set; }

        // Navigation properties
        public ICollection<Review> Reviews { get; set; } = new List<Review>();
        public ICollection<OrderItem> OrderItems { get; set; } = new List<OrderItem>();
    }

    public enum DeviceCategory
    {
        EducationalToy,      // Đồ chơi giáo dục
        ElectronicDevice,    // Thiết bị điện tử
        SafetyDevice,        // Thiết bị an toàn
        Monitor,             // Thiết bị giám sát
        SmartWatch,          // Đồng hồ thông minh
        Tablet,              // Máy tính bảng
        Other                // Khác
    }
}
