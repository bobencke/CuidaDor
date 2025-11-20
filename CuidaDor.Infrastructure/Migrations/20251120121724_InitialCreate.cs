using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

#pragma warning disable CA1814 // Prefer jagged arrays over multidimensional

namespace CuidaDor.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class InitialCreate : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "ReliefTechniques",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Name = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    ShortDescription = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    WarningText = table.Column<string>(type: "nvarchar(max)", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_ReliefTechniques", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "Users",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Email = table.Column<string>(type: "nvarchar(450)", nullable: false),
                    FullName = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    Age = table.Column<int>(type: "int", nullable: true),
                    Sex = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    PhoneNumber = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    PasswordHash = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Users", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "TechniqueSteps",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    ReliefTechniqueId = table.Column<int>(type: "int", nullable: false),
                    Order = table.Column<int>(type: "int", nullable: false),
                    Description = table.Column<string>(type: "nvarchar(max)", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_TechniqueSteps", x => x.Id);
                    table.ForeignKey(
                        name: "FK_TechniqueSteps_ReliefTechniques_ReliefTechniqueId",
                        column: x => x.ReliefTechniqueId,
                        principalTable: "ReliefTechniques",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "AccessibilityPreferences",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    UserId = table.Column<int>(type: "int", nullable: false),
                    FontScale = table.Column<double>(type: "float", nullable: false),
                    HighContrast = table.Column<bool>(type: "bit", nullable: false),
                    VoiceReading = table.Column<bool>(type: "bit", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_AccessibilityPreferences", x => x.Id);
                    table.ForeignKey(
                        name: "FK_AccessibilityPreferences_Users_UserId",
                        column: x => x.UserId,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "ConsentLgpds",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    UserId = table.Column<int>(type: "int", nullable: false),
                    Accepted = table.Column<bool>(type: "bit", nullable: false),
                    AcceptedAt = table.Column<DateTime>(type: "datetime2", nullable: true),
                    PolicyVersion = table.Column<string>(type: "nvarchar(max)", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_ConsentLgpds", x => x.Id);
                    table.ForeignKey(
                        name: "FK_ConsentLgpds_Users_UserId",
                        column: x => x.UserId,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "GeneralFeedbacks",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    UserId = table.Column<int>(type: "int", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false),
                    Text = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    GeneralFeeling = table.Column<int>(type: "int", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_GeneralFeedbacks", x => x.Id);
                    table.ForeignKey(
                        name: "FK_GeneralFeedbacks_Users_UserId",
                        column: x => x.UserId,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "PainAssessments",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    UserId = table.Column<int>(type: "int", nullable: false),
                    Date = table.Column<DateTime>(type: "datetime2", nullable: false),
                    UsualPain = table.Column<int>(type: "int", nullable: false),
                    LocalizedPain = table.Column<int>(type: "int", nullable: false),
                    MoodToday = table.Column<int>(type: "int", nullable: false),
                    SleepQuality = table.Column<int>(type: "int", nullable: false),
                    LimitsPhysicalActivities = table.Column<bool>(type: "bit", nullable: false),
                    PainWorseWithMovement = table.Column<bool>(type: "bit", nullable: false),
                    UsesPainMedication = table.Column<bool>(type: "bit", nullable: false),
                    UsesNonDrugPainRelief = table.Column<bool>(type: "bit", nullable: false),
                    Notes = table.Column<string>(type: "nvarchar(max)", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_PainAssessments", x => x.Id);
                    table.ForeignKey(
                        name: "FK_PainAssessments_Users_UserId",
                        column: x => x.UserId,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "TechniqueSessions",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    UserId = table.Column<int>(type: "int", nullable: false),
                    ReliefTechniqueId = table.Column<int>(type: "int", nullable: false),
                    StartedAt = table.Column<DateTime>(type: "datetime2", nullable: false),
                    FinishedAt = table.Column<DateTime>(type: "datetime2", nullable: false),
                    ResultFeeling = table.Column<int>(type: "int", nullable: false),
                    Notes = table.Column<string>(type: "nvarchar(max)", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_TechniqueSessions", x => x.Id);
                    table.ForeignKey(
                        name: "FK_TechniqueSessions_ReliefTechniques_ReliefTechniqueId",
                        column: x => x.ReliefTechniqueId,
                        principalTable: "ReliefTechniques",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_TechniqueSessions_Users_UserId",
                        column: x => x.UserId,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "UserComorbidities",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    UserId = table.Column<int>(type: "int", nullable: false),
                    Name = table.Column<string>(type: "nvarchar(max)", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_UserComorbidities", x => x.Id);
                    table.ForeignKey(
                        name: "FK_UserComorbidities_Users_UserId",
                        column: x => x.UserId,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.InsertData(
                table: "ReliefTechniques",
                columns: new[] { "Id", "Name", "ShortDescription", "WarningText" },
                values: new object[,]
                {
                    { 1, "Respiração 4-7-8", "Respiração • Ansiedade e sono", "Pode dar leve tontura no início" },
                    { 2, "Respiração profunda", "Respiração • Reduz tensão e dor", null },
                    { 3, "Alongamento de mãos", "Alongamentos • Rigidez matinal", "Pare se houver dor forte" },
                    { 4, "Relaxamento muscular progressivo", "Relaxamento • Tensão corporal", null },
                    { 5, "Toque calmante", "Relaxamento • Conforto imediato", null },
                    { 6, "Calor morno local", "Termoterapia • Rigidez e desconforto", "Evite pele lesionada; teste a temperatura" }
                });

            migrationBuilder.InsertData(
                table: "TechniqueSteps",
                columns: new[] { "Id", "Description", "Order", "ReliefTechniqueId" },
                values: new object[,]
                {
                    { 1, "Inspire pelo nariz contando até 4.", 1, 1 },
                    { 2, "Segure o ar contando até 7.", 2, 1 },
                    { 3, "Expire pela boca contando até 8.", 3, 1 },
                    { 4, "Repita por 4 ciclos completos.", 4, 1 }
                });

            migrationBuilder.CreateIndex(
                name: "IX_AccessibilityPreferences_UserId",
                table: "AccessibilityPreferences",
                column: "UserId",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_ConsentLgpds_UserId",
                table: "ConsentLgpds",
                column: "UserId",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_GeneralFeedbacks_UserId",
                table: "GeneralFeedbacks",
                column: "UserId");

            migrationBuilder.CreateIndex(
                name: "IX_PainAssessments_UserId",
                table: "PainAssessments",
                column: "UserId");

            migrationBuilder.CreateIndex(
                name: "IX_TechniqueSessions_ReliefTechniqueId",
                table: "TechniqueSessions",
                column: "ReliefTechniqueId");

            migrationBuilder.CreateIndex(
                name: "IX_TechniqueSessions_UserId",
                table: "TechniqueSessions",
                column: "UserId");

            migrationBuilder.CreateIndex(
                name: "IX_TechniqueSteps_ReliefTechniqueId",
                table: "TechniqueSteps",
                column: "ReliefTechniqueId");

            migrationBuilder.CreateIndex(
                name: "IX_UserComorbidities_UserId",
                table: "UserComorbidities",
                column: "UserId");

            migrationBuilder.CreateIndex(
                name: "IX_Users_Email",
                table: "Users",
                column: "Email",
                unique: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "AccessibilityPreferences");

            migrationBuilder.DropTable(
                name: "ConsentLgpds");

            migrationBuilder.DropTable(
                name: "GeneralFeedbacks");

            migrationBuilder.DropTable(
                name: "PainAssessments");

            migrationBuilder.DropTable(
                name: "TechniqueSessions");

            migrationBuilder.DropTable(
                name: "TechniqueSteps");

            migrationBuilder.DropTable(
                name: "UserComorbidities");

            migrationBuilder.DropTable(
                name: "ReliefTechniques");

            migrationBuilder.DropTable(
                name: "Users");
        }
    }
}
