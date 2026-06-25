using Amazon.S3;
using Amazon.S3.Model;
using Amazon.SimpleEmail;
using Amazon.SimpleEmail.Model;
using Microsoft.AspNetCore.Mvc;

namespace TaskApi.Controllers;

[ApiController]
[Route("api/[controller]")]
public class AssetsController : ControllerBase
{
    private readonly IAmazonS3 _s3;
    private readonly IAmazonSimpleEmailService _ses;
    private readonly string _bucketName;
    private readonly string _senderEmail;

    public AssetsController(IAmazonS3 s3, IAmazonSimpleEmailService ses)
    {
        _s3 = s3;
        _ses = ses;
        _bucketName = Environment.GetEnvironmentVariable("BUCKET_NAME")
            ?? throw new Exception("BUCKET_NAME env var not set");
        _senderEmail = Environment.GetEnvironmentVariable("SES_SENDER_EMAIL")
            ?? throw new Exception("SES_SENDER_EMAIL not set");
    }

    [HttpGet("{filename}")]
    public async Task<IActionResult> GetPresignedUrl(string filename, [FromQuery] string email)
    {
        if (string.IsNullOrEmpty(email))
            return BadRequest(new { message = "email query parameter is required" });
        // check file exists in S3 first
        try
        {
            await _s3.GetObjectMetadataAsync(_bucketName, filename);
        }
        catch (AmazonS3Exception ex) when (ex.StatusCode == System.Net.HttpStatusCode.NotFound)
        {
            return NotFound(new { message = $"{filename} not found in bucket" });
        }

        // generate presigned URL valid for 15 minutes
        var request = new GetPreSignedUrlRequest
        {
            BucketName = _bucketName,
            Key = filename,
            Expires = DateTime.UtcNow.AddMinutes(2),
            Verb = HttpVerb.GET
        };

        var url = _s3.GetPreSignedURL(request);

        _ = SendEmailAsync(email, filename, url);

        return Ok(new
        {
            message = $"Presigned URL sent to {email}",
            expiresInMinutes = 2
        });
    }

    public async Task SendEmailAsync(string email, string filename, string url)
    {
        var sendRequest = new SendEmailRequest
        {
            Source = _senderEmail,
            Destination = new Destination
            {
                ToAddresses = new List<string> { email }
            },
            Message = new Message
            {
                Subject = new Content($"Your download link for {filename}"),
                Body = new Body
                {
                    Html = new Content($@"
                        <h2>Your file is ready</h2>
                        <p>You requested access to <strong>{filename}</strong>.</p>
                        <p>Click the link below to download it:</p>
                        <a href='{url}'>Download {filename}</a>
                        <p>This link expires in 15 minutes.</p>
                    "),
                    Text = new Content($@"
                        Your file is ready.
                        Download {filename} here: {url}
                        This link expires in 2 minutes.
                    ")
                }
            }
        };

        await _ses.SendEmailAsync(sendRequest);
    }
}