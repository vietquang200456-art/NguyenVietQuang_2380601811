using Microsoft.EntityFrameworkCore;
using Server.Models;

namespace Server.Data
{
    public class ApplicationDbContext : DbContext
    {
        public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options)
            : base(options)
        {
        }

        public DbSet<User> Users { get; set; }
        public DbSet<Device> Devices { get; set; }
        public DbSet<Order> Orders { get; set; }
        public DbSet<OrderItem> OrderItems { get; set; }
        public DbSet<Review> Reviews { get; set; }

        protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
        {
            base.OnConfiguring(optionsBuilder);
            // Suppress pending model changes warning
            optionsBuilder.ConfigureWarnings(warnings =>
                warnings.Ignore(Microsoft.EntityFrameworkCore.Diagnostics.RelationalEventId.PendingModelChangesWarning));
        }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            // User configuration
            modelBuilder.Entity<User>(entity =>
            {
                entity.HasKey(e => e.Id);
                entity.HasIndex(e => e.Username).IsUnique();
                entity.HasIndex(e => e.Email).IsUnique();
                entity.Property(e => e.Username).IsRequired().HasMaxLength(50);
                entity.Property(e => e.Email).IsRequired().HasMaxLength(100);
                entity.Property(e => e.PasswordHash).IsRequired();
                entity.Property(e => e.FullName).IsRequired().HasMaxLength(100);
                entity.Property(e => e.PhoneNumber).HasMaxLength(20);
            });

            // Device configuration
            modelBuilder.Entity<Device>(entity =>
            {
                entity.HasKey(e => e.Id);
                entity.Property(e => e.Name).IsRequired().HasMaxLength(200);
                entity.Property(e => e.Description).HasMaxLength(1000);
                entity.Property(e => e.Price).HasColumnType("decimal(18,2)");
                entity.Property(e => e.Brand).HasMaxLength(100);
                entity.Property(e => e.ModelNumber).HasMaxLength(100);
                entity.Property(e => e.ImageUrl).HasMaxLength(500);

                entity.HasOne(e => e.Creator)
                    .WithMany(u => u.Devices)
                    .HasForeignKey(e => e.CreatedBy)
                    .OnDelete(DeleteBehavior.Restrict);
            });

            // Order configuration
            modelBuilder.Entity<Order>(entity =>
            {
                entity.HasKey(e => e.Id);
                entity.HasIndex(e => e.OrderNumber).IsUnique();
                entity.Property(e => e.OrderNumber).IsRequired().HasMaxLength(50);
                entity.Property(e => e.TotalAmount).HasColumnType("decimal(18,2)");
                entity.Property(e => e.ShippingAddress).HasMaxLength(500);
                entity.Property(e => e.PhoneNumber).HasMaxLength(20);
                entity.Property(e => e.Notes).HasMaxLength(1000);

                entity.HasOne(e => e.User)
                    .WithMany()
                    .HasForeignKey(e => e.UserId)
                    .OnDelete(DeleteBehavior.Restrict);
            });

            // OrderItem configuration
            modelBuilder.Entity<OrderItem>(entity =>
            {
                entity.HasKey(e => e.Id);
                entity.Property(e => e.UnitPrice).HasColumnType("decimal(18,2)");
                entity.Property(e => e.TotalPrice).HasColumnType("decimal(18,2)");

                entity.HasOne(e => e.Order)
                    .WithMany(o => o.OrderItems)
                    .HasForeignKey(e => e.OrderId)
                    .OnDelete(DeleteBehavior.Cascade);

                entity.HasOne(e => e.Device)
                    .WithMany(d => d.OrderItems)
                    .HasForeignKey(e => e.DeviceId)
                    .OnDelete(DeleteBehavior.Restrict);
            });

            // Review configuration
            modelBuilder.Entity<Review>(entity =>
            {
                entity.HasKey(e => e.Id);
                entity.Property(e => e.Rating).IsRequired();
                entity.Property(e => e.Comment).HasMaxLength(1000);

                entity.HasOne(e => e.User)
                    .WithMany()
                    .HasForeignKey(e => e.UserId)
                    .OnDelete(DeleteBehavior.Restrict);

                entity.HasOne(e => e.Device)
                    .WithMany(d => d.Reviews)
                    .HasForeignKey(e => e.DeviceId)
                    .OnDelete(DeleteBehavior.Cascade);

                // Unique constraint: One review per user per device
                entity.HasIndex(e => new { e.UserId, e.DeviceId }).IsUnique();
            });

            // Seed data
            SeedData(modelBuilder);
        }

        private void SeedData(ModelBuilder modelBuilder)
        {
            // Seed Admin User (password: Admin@123)
            modelBuilder.Entity<User>().HasData(
                new User
                {
                    Id = 1,
                    Username = "admin",
                    Email = "admin@childdevices.com",
                    PasswordHash = BCrypt.Net.BCrypt.HashPassword("Admin@123"),
                    FullName = "System Administrator",
                    PhoneNumber = "0123456789",
                    Role = UserRole.Admin,
                    CreatedAt = DateTime.UtcNow,
                    IsActive = true
                }
            );

            // Seed Sample Devices
            modelBuilder.Entity<Device>().HasData(
                new Device
                {
                    Id = 1,
                    Name = "Đồng hồ thông minh trẻ em Kiddo Watch Pro",
                    Description = "Đồng hồ thông minh với GPS, gọi điện, camera và theo dõi sức khỏe",
                    Category = DeviceCategory.SmartWatch,
                    Price = 1990000,
                    Brand = "Kiddo",
                    ModelNumber = "KW-PRO-2024",
                    ImageUrl = "https://example.com/images/kiddo-watch.jpg",
                    StockQuantity = 50,
                    MinAge = 5,
                    MaxAge = 12,
                    IsAvailable = true,
                    CreatedBy = 1,
                    CreatedAt = DateTime.UtcNow
                },
                new Device
                {
                    Id = 2,
                    Name = "Máy tính bảng học tập Samsung Kids Tab",
                    Description = "Máy tính bảng chuyên dụng cho trẻ em với nội dung giáo dục phong phú",
                    Category = DeviceCategory.Tablet,
                    Price = 4990000,
                    Brand = "Samsung",
                    ModelNumber = "ST-K10-2024",
                    ImageUrl = "https://example.com/images/samsung-kids-tab.jpg",
                    StockQuantity = 30,
                    MinAge = 4,
                    MaxAge = 14,
                    IsAvailable = true,
                    CreatedBy = 1,
                    CreatedAt = DateTime.UtcNow
                },
                new Device
                {
                    Id = 3,
                    Name = "Robot giáo dục lập trình CodeBot",
                    Description = "Robot thông minh giúp trẻ học lập trình cơ bản qua trò chơi",
                    Category = DeviceCategory.EducationalToy,
                    Price = 2490000,
                    Brand = "CodeBot",
                    ModelNumber = "CB-EDU-100",
                    ImageUrl = "https://example.com/images/codebot.jpg",
                    StockQuantity = 40,
                    MinAge = 6,
                    MaxAge = 15,
                    IsAvailable = true,
                    CreatedBy = 1,
                    CreatedAt = DateTime.UtcNow
                },
                new Device
                {
                    Id = 4,
                    Name = "Camera giám sát an toàn SafeBaby Monitor",
                    Description = "Camera theo dõi em bé với tính năng xem qua điện thoại, cảnh báo khóc",
                    Category = DeviceCategory.Monitor,
                    Price = 1590000,
                    Brand = "SafeBaby",
                    ModelNumber = "SB-MON-360",
                    ImageUrl = "https://example.com/images/safebaby-monitor.jpg",
                    StockQuantity = 25,
                    MinAge = 0,
                    MaxAge = 5,
                    IsAvailable = true,
                    CreatedBy = 1,
                    CreatedAt = DateTime.UtcNow
                },
                new Device
                {
                    Id = 5,
                    Name = "Thiết bị định vị GPS cho trẻ KidTracker",
                    Description = "Thiết bị định vị GPS nhỏ gọn, pin dùng lâu, chống nước",
                    Category = DeviceCategory.SafetyDevice,
                    Price = 890000,
                    Brand = "KidTracker",
                    ModelNumber = "KT-GPS-2024",
                    ImageUrl = "https://example.com/images/kidtracker.jpg",
                    StockQuantity = 60,
                    MinAge = 3,
                    MaxAge = 12,
                    IsAvailable = true,
                    CreatedBy = 1,
                    CreatedAt = DateTime.UtcNow
                }
            );
        }
    }
}

