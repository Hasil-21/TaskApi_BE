using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using TaskApi.Data;
using TaskApi.Models;
using Amazon.SQS;
using Amazon.SQS.Model;
using System.Text.Json;

namespace TaskApi.Controllers;

[ApiController]
[Route("api/[controller]")]
public class TasksController : ControllerBase
{
    private readonly AppDbContext _db;
    private readonly IAmazonSQS _sqs;
    public TasksController(AppDbContext db,IAmazonSQS sqs)
    {
        _db=db;
        _sqs=sqs;
    }

    [HttpGet("{id}")]
    public async Task<IActionResult> GetById(int id)
    {
        var task = await _db.Tasks.FindAsync(id);
        return task is null ? NotFound() : Ok(
            await _sqs.SendMessageAsync(new SendMessageRequest
            {
                QueueUrl = "https://sqs.ap-south-1.amazonaws.com/292578125952/demo-queue",
                MessageBody = JsonSerializer.Serialize(task)
            })
        );
    }

    [HttpPost]
    public async Task<IActionResult> Create(TaskItems task)
    {
        _db.Tasks.Add(task);
        await _db.SaveChangesAsync();
        return CreatedAtAction(nameof(GetById), new { id = task.Id }, task);
    }

    [HttpPut("{id}")]
    public async Task<IActionResult> Update(int id, TaskItems updated)
    {
        var task = await _db.Tasks.FindAsync(id);
        if (task is null) return NotFound();
        task.Title = updated.Title;
        task.IsCompleted = updated.IsCompleted;
        await _db.SaveChangesAsync();
        return Ok(task);
    }

    [HttpDelete("{id}")]
    public async Task<IActionResult> Delete(int id)
    {
        var task = await _db.Tasks.FindAsync(id);
        if (task is null) return NotFound();
        _db.Tasks.Remove(task);
        await _db.SaveChangesAsync();
        return NoContent();
    }
}