namespace Server.Models
{
    public class User
    {
        public int Id { get; set; }
        public string Email { get; set; } = string.Empty;
        public string PasswordHash { get; set; } = string.Empty;
        public string FullName { get; set; } = string.Empty;
        public string? PhoneNumber { get; set; }
        public UserRole Role { get; set; } = UserRole.User;
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        public DateTime? UpdatedAt { get; set; }
        public bool IsActive { get; set; } = true;

        // Navigation property
        public ICollection<Device> Devices { get; set; } = new List<Device>();
    }

    public enum UserRole
    {
        User,
        Admin
    }
}
