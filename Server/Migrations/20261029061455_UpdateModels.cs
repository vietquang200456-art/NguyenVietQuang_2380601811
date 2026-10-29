using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Server.Migrations
{
    /// <inheritdoc />
    public partial class UpdateModels : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
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

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.UpdateData(
                table: "Devices",
                keyColumn: "Id",
                keyValue: 1,
                column: "CreatedAt",
                value: new DateTime(2026, 10, 29, 6, 11, 21, 946, DateTimeKind.Utc).AddTicks(5790));

            migrationBuilder.UpdateData(
                table: "Devices",
                keyColumn: "Id",
                keyValue: 2,
                column: "CreatedAt",
                value: new DateTime(2026, 10, 29, 6, 11, 21, 946, DateTimeKind.Utc).AddTicks(6257));

            migrationBuilder.UpdateData(
                table: "Devices",
                keyColumn: "Id",
                keyValue: 3,
                column: "CreatedAt",
                value: new DateTime(2026, 10, 29, 6, 11, 21, 946, DateTimeKind.Utc).AddTicks(6264));

            migrationBuilder.UpdateData(
                table: "Devices",
                keyColumn: "Id",
                keyValue: 4,
                column: "CreatedAt",
                value: new DateTime(2026, 10, 29, 6, 11, 21, 946, DateTimeKind.Utc).AddTicks(6269));

            migrationBuilder.UpdateData(
                table: "Devices",
                keyColumn: "Id",
                keyValue: 5,
                column: "CreatedAt",
                value: new DateTime(2026, 10, 29, 6, 11, 21, 946, DateTimeKind.Utc).AddTicks(6274));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 1,
                columns: new[] { "CreatedAt", "PasswordHash" },
                values: new object[] { new DateTime(2026, 10, 29, 6, 11, 21, 943, DateTimeKind.Utc).AddTicks(7156), "$2a$11$dKYf3OUSMLzQacjFqPZeBeabmczo4YPcZEyWuBfVoq713jB5dfyy2" });
        }
    }
}
