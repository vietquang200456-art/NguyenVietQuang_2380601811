using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Server.Migrations
{
    /// <inheritdoc />
    public partial class FinalMigration : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.UpdateData(
                table: "Devices",
                keyColumn: "Id",
                keyValue: 1,
                column: "CreatedAt",
                value: new DateTime(2026, 10, 29, 6, 34, 28, 396, DateTimeKind.Utc).AddTicks(5683));

            migrationBuilder.UpdateData(
                table: "Devices",
                keyColumn: "Id",
                keyValue: 2,
                column: "CreatedAt",
                value: new DateTime(2026, 10, 29, 6, 34, 28, 396, DateTimeKind.Utc).AddTicks(5775));

            migrationBuilder.UpdateData(
                table: "Devices",
                keyColumn: "Id",
                keyValue: 3,
                column: "CreatedAt",
                value: new DateTime(2026, 10, 29, 6, 34, 28, 396, DateTimeKind.Utc).AddTicks(5777));

            migrationBuilder.UpdateData(
                table: "Devices",
                keyColumn: "Id",
                keyValue: 4,
                column: "CreatedAt",
                value: new DateTime(2026, 10, 29, 6, 34, 28, 396, DateTimeKind.Utc).AddTicks(5810));

            migrationBuilder.UpdateData(
                table: "Devices",
                keyColumn: "Id",
                keyValue: 5,
                column: "CreatedAt",
                value: new DateTime(2026, 10, 29, 6, 34, 28, 396, DateTimeKind.Utc).AddTicks(5812));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 1,
                columns: new[] { "CreatedAt", "PasswordHash" },
                values: new object[] { new DateTime(2026, 10, 29, 6, 34, 28, 395, DateTimeKind.Utc).AddTicks(6919), "$2a$11$E4yLWh8ERMtFqxt9F9y6teKsTS3TBOA2xk5QBEtkL6fi.nfHx9TZC" });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.UpdateData(
                table: "Devices",
                keyColumn: "Id",
                keyValue: 1,
                column: "CreatedAt",
                value: new DateTime(2026, 10, 29, 6, 30, 8, 49, DateTimeKind.Utc).AddTicks(8819));

            migrationBuilder.UpdateData(
                table: "Devices",
                keyColumn: "Id",
                keyValue: 2,
                column: "CreatedAt",
                value: new DateTime(2026, 10, 29, 6, 30, 8, 49, DateTimeKind.Utc).AddTicks(8919));

            migrationBuilder.UpdateData(
                table: "Devices",
                keyColumn: "Id",
                keyValue: 3,
                column: "CreatedAt",
                value: new DateTime(2026, 10, 29, 6, 30, 8, 49, DateTimeKind.Utc).AddTicks(8923));

            migrationBuilder.UpdateData(
                table: "Devices",
                keyColumn: "Id",
                keyValue: 4,
                column: "CreatedAt",
                value: new DateTime(2026, 10, 29, 6, 30, 8, 49, DateTimeKind.Utc).AddTicks(8927));

            migrationBuilder.UpdateData(
                table: "Devices",
                keyColumn: "Id",
                keyValue: 5,
                column: "CreatedAt",
                value: new DateTime(2026, 10, 29, 6, 30, 8, 49, DateTimeKind.Utc).AddTicks(8930));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 1,
                columns: new[] { "CreatedAt", "PasswordHash" },
                values: new object[] { new DateTime(2026, 10, 29, 6, 30, 8, 49, DateTimeKind.Utc).AddTicks(1950), "$2a$11$3ELix.QYALtyBbXijsJHUeP6eoAn2ecHkcQLRtCqkyye0IjYau5Oa" });
        }
    }
}
