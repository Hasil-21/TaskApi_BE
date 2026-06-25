using Amazon.S3;
using Amazon.S3.Model;
using Microsoft.AspNetCore.Mvc;

namespace TaskApi.Controllers;

[ApiController]
[Route("api/[controller]")]
public class AssetsController : ControllerBase
{
    private readonly IAmazonS3 _s3;
    private readonly string _bucketName;

    public AssetsController(IAmazonS3 s3)
    {
        _s3 = s3;
        _bucketName = Environment.GetEnvironmentVariable("ASSETS_BUCKET")
            ?? throw new Exception("ASSETS_BUCKET env var not set");
    }

    [HttpGet("{filename}")]
    public async Task<IActionResult> GetPresignedUrl(string filename)
    {
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

        return Ok(new
        {
            filename = filename,
            url = url,
            expiresInMinutes = 2
        });
    }
}