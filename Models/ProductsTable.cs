namespace TaskApi.Models;

public class ProductsTable
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public bool IsAvailable { get; set; }
    public int Price { get; set; }
}