using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Server.Migrations
{
    /// <inheritdoc />
    public partial class ApplyPendingChanges : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.UpdateData(
                table: "Devices",
                keyColumn: "Id",
                keyValue: 1,
                column: "CreatedAt",
                value: new DateTime(2026, 10, 29, 6, 16, 7, 373, DateTimeKind.Utc).AddTicks(4563));

            migrationBuilder.UpdateData(
                table: "Devices",
                keyColumn: "Id",
                keyValue: 2,
                column: "CreatedAt",
                value: new DateTime(2026, 10, 29, 6, 16, 7, 373, DateTimeKind.Utc).AddTicks(4725));

            migrationBuilder.UpdateData(
                table: "Devices",
                keyColumn: "Id",
                keyValue: 3,
                column: "CreatedAt",
                value: new DateTime(2026, 10, 29, 6, 16, 7, 373, DateTimeKind.Utc).AddTicks(4729));

            migrationBuilder.UpdateData(
                table: "Devices",
                keyColumn: "Id",
                keyValue: 4,
                column: "CreatedAt",
                value: new DateTime(2026, 10, 29, 6, 16, 7, 373, DateTimeKind.Utc).AddTicks(4733));

            migrationBuilder.UpdateData(
                table: "Devices",
                keyColumn: "Id",
                keyValue: 5,
                column: "CreatedAt",
                value: new DateTime(2026, 10, 29, 6, 16, 7, 373, DateTimeKind.Utc).AddTicks(4736));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 1,
                columns: new[] { "CreatedAt", "PasswordHash" },
                values: new object[] { new DateTime(2026, 10, 29, 6, 16, 7, 372, DateTimeKind.Utc).AddTicks(4644), "$2a$11$Zt.N74KTUXBgdUjw8QJh4.JG8OD7cbiMlKRiUG8BaOuWUlyX6gRHm" });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.UpdateData(
                table: "Devices",
                keyColumn: "Id",
                keyValue: 1,
                column: "CreatedAt",
                value: new DateTime(2026, 10, 29, 6, 14, 54, 956, DateTimeKind.Utc).AddTicks(4144));

            migrationBuilder.UpdateData(
                table: "Devices",
                keyColumn: "Id",
                keyValue: 2,
                column: "CreatedAt",
                value: new DateTime(2026, 10, 29, 6, 14, 54, 956, DateTimeKind.Utc).AddTicks(4233));

            migrationBuilder.UpdateData(
                table: "Devices",
                keyColumn: "Id",
                keyValue: 3,
                column: "CreatedAt",
                value: new DateTime(2026, 10, 29, 6, 14, 54, 956, DateTimeKind.Utc).AddTicks(4236));

            migrationBuilder.UpdateData(
                table: "Devices",
                keyColumn: "Id",
                keyValue: 4,
                column: "CreatedAt",
                value: new DateTime(2026, 10, 29, 6, 14, 54, 956, DateTimeKind.Utc).AddTicks(4238));

            migrationBuilder.UpdateData(
                table: "Devices",
                keyColumn: "Id",
                keyValue: 5,
                column: "CreatedAt",
                value: new DateTime(2026, 10, 29, 6, 14, 54, 956, DateTimeKind.Utc).AddTicks(4240));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 1,
                columns: new[] { "CreatedAt", "PasswordHash" },
                values: new object[] { new DateTime(2026, 10, 29, 6, 14, 54, 955, DateTimeKind.Utc).AddTicks(6929), "$2a$11$8ArT6enTz1exelOB60LzxeYqOFn2KJ/tRPGa8niWrBkjAWeh0sIs6" });
        }
    }
}
