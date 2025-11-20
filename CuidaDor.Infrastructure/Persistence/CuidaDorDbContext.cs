using CuidaDor.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CuidaDor.Infrastructure.Persistence
{
    public class CuidaDorDbContext : DbContext
    {
        public CuidaDorDbContext(DbContextOptions<CuidaDorDbContext> options) : base(options) { }

        public DbSet<User> Users => Set<User>();
        public DbSet<UserComorbidity> UserComorbidities => Set<UserComorbidity>();
        public DbSet<AccessibilityPreference> AccessibilityPreferences => Set<AccessibilityPreference>();
        public DbSet<ConsentLgpd> ConsentLgpds => Set<ConsentLgpd>();
        public DbSet<PainAssessment> PainAssessments => Set<PainAssessment>();
        public DbSet<ReliefTechnique> ReliefTechniques => Set<ReliefTechnique>();
        public DbSet<TechniqueStep> TechniqueSteps => Set<TechniqueStep>();
        public DbSet<TechniqueSession> TechniqueSessions => Set<TechniqueSession>();
        public DbSet<GeneralFeedback> GeneralFeedbacks => Set<GeneralFeedback>();

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            modelBuilder.Entity<User>()
                .HasIndex(u => u.Email)
                .IsUnique();

            modelBuilder.Entity<User>()
                .HasOne(u => u.AccessibilityPreference)
                .WithOne(a => a.User)
                .HasForeignKey<AccessibilityPreference>(a => a.UserId);

            modelBuilder.Entity<User>()
                .HasOne(u => u.ConsentLgpd)
                .WithOne(c => c.User)
                .HasForeignKey<ConsentLgpd>(c => c.UserId);

            modelBuilder.Entity<ReliefTechnique>().HasData(
                new ReliefTechnique { Id = 1, Name = "Respiração 4-7-8", ShortDescription = "Respiração • Ansiedade e sono", WarningText = "Pode dar leve tontura no início" },
                new ReliefTechnique { Id = 2, Name = "Respiração profunda", ShortDescription = "Respiração • Reduz tensão e dor" },
                new ReliefTechnique { Id = 3, Name = "Alongamento de mãos", ShortDescription = "Alongamentos • Rigidez matinal", WarningText = "Pare se houver dor forte" },
                new ReliefTechnique { Id = 4, Name = "Relaxamento muscular progressivo", ShortDescription = "Relaxamento • Tensão corporal" },
                new ReliefTechnique { Id = 5, Name = "Toque calmante", ShortDescription = "Relaxamento • Conforto imediato" },
                new ReliefTechnique { Id = 6, Name = "Calor morno local", ShortDescription = "Termoterapia • Rigidez e desconforto", WarningText = "Evite pele lesionada; teste a temperatura" }
            );

            modelBuilder.Entity<TechniqueStep>().HasData(
                new TechniqueStep { Id = 1, ReliefTechniqueId = 1, Order = 1, Description = "Inspire pelo nariz contando até 4." },
                new TechniqueStep { Id = 2, ReliefTechniqueId = 1, Order = 2, Description = "Segure o ar contando até 7." },
                new TechniqueStep { Id = 3, ReliefTechniqueId = 1, Order = 3, Description = "Expire pela boca contando até 8." },
                new TechniqueStep { Id = 4, ReliefTechniqueId = 1, Order = 4, Description = "Repita por 4 ciclos completos." }
            );
        }
    }
}
