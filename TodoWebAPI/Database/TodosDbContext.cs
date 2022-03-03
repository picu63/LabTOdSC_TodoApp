using Microsoft.EntityFrameworkCore;
namespace TodoWebAPI.Database
{
    public class TodosDbContext : DbContext
    {
        public TodosDbContext(DbContextOptions options) : base(options)
        {
            base.Database.EnsureCreated();
        }
        public DbSet<Todo> Todos { get; set; }
    }
}
