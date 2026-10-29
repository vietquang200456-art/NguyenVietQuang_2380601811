namespace Server.Models
{
    public class Review
    {
        public int Id { get; set; }
        public int UserId { get; set; }
        public User? User { get; set; }
        public int DeviceId { get; set; }
        public Device? Device { get; set; }
        public int Rating { get; set; } // 1-5 sao
        public string? Comment { get; set; }
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        public DateTime? UpdatedAt { get; set; }
    }
}
