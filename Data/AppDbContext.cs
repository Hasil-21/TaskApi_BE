using Microsoft.EntityFrameworkCore;
using TaskApi.Models;

namespace TaskApi.Data;

public class AppDbContext: DbContext
{
    public AppDbContext(DbContextOptions<AppDbContext> options):base(options){}
    public DbSet<TaskItems> Tasks => Set<TaskItems>();
    public DbSet<ProductsTable> Products => Set<ProductsTable>();
}