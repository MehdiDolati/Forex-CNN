using System;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata;

#nullable disable

namespace CNNBridge.Models
{
    public partial class DBContext : DbContext
    {
        public DBContext()
        {
        }

        public DBContext(DbContextOptions<DBContext> options)
            : base(options)
        {
        }

        public virtual DbSet<Model> Models { get; set; }
        public virtual DbSet<PredictedValue> PredictedValues { get; set; }
        public virtual DbSet<Prediction> Predictions { get; set; }

        protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
        {
            if (!optionsBuilder.IsConfigured)
            {
#warning To protect potentially sensitive information in your connection string, you should move it out of source code. You can avoid scaffolding the connection string by using the Name= syntax to read it from configuration - see https://go.microsoft.com/fwlink/?linkid=2131148. For more guidance on storing connection strings, see http://go.microsoft.com/fwlink/?LinkId=723263.
                optionsBuilder.UseSqlServer("Data Source=(LocalDB)\\MSSQLLocalDB;AttachDbFilename=|DataDirectory|ForexModelsDB.mdf;Integrated Security=True");
            }
        }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            modelBuilder.HasAnnotation("Relational:Collation", "SQL_Latin1_General_CP1_CI_AS");

            modelBuilder.Entity<Model>(entity =>
            {
                entity.ToTable("Model");

                entity.Property(e => e.Name)
                    .IsRequired()
                    .HasMaxLength(256);
            });

            modelBuilder.Entity<PredictedValue>(entity =>
            {
                entity.Property(e => e.ClassLabel)
                    .IsRequired()
                    .HasMaxLength(50);

                entity.Property(e => e.PredictedValue1).HasColumnName("PredictedValue");

                entity.HasOne(d => d.Prediction)
                    .WithMany(p => p.PredictedValues)
                    .HasForeignKey(d => d.PredictionId)
                    .OnDelete(DeleteBehavior.ClientSetNull)
                    .HasConstraintName("FK_PredictedValues_Prediction");
            });

            modelBuilder.Entity<Prediction>(entity =>
            {
                entity.ToTable("Prediction");

                entity.Property(e => e.Description).HasMaxLength(256);

                entity.Property(e => e.Signal).HasDefaultValueSql("((2))");

                entity.Property(e => e.Time).HasDefaultValueSql("(getdate())");

                entity.Property(e => e.Tp).HasColumnName("TP");

                entity.Property(e => e.UpdateDate).HasColumnType("datetime");

                entity.HasOne(d => d.Model)
                    .WithMany(p => p.Predictions)
                    .HasForeignKey(d => d.ModelId)
                    .OnDelete(DeleteBehavior.ClientSetNull)
                    .HasConstraintName("FK_Prediction_Model");
            });

            OnModelCreatingPartial(modelBuilder);
        }

        partial void OnModelCreatingPartial(ModelBuilder modelBuilder);
    }
}
