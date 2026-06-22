using Amazon.Lambda.Core;
using Amazon.Lambda.SQSEvents;
using Amazon.SimpleNotificationService;
using Amazon.SimpleNotificationService.Model;

[assembly: LambdaSerializer(typeof(Amazon.Lambda.Serialization.SystemTextJson.DefaultLambdaJsonSerializer))]

namespace SqsProcessor;

public class Function
{
    private readonly IAmazonSimpleNotificationService _snsClient;
    private readonly string _snsTopicArn;

    public Function()
    {
        _snsClient = new AmazonSimpleNotificationServiceClient();
        _snsTopicArn = Environment.GetEnvironmentVariable("SNS_TOPIC_ARN")!;
    }

    public async Task FunctionHandler(SQSEvent sqsEvent, ILambdaContext context)
    {
        foreach (var message in sqsEvent.Records)
        {
            context.Logger.LogInformation($"Processing message: {message.MessageId}");

            // send raw message body to SNS
            await _snsClient.PublishAsync(new PublishRequest
            {
                TopicArn = _snsTopicArn,
                Subject = "New SQS Message",
                Message = message.Body   // raw SQS message body
            });

            context.Logger.LogInformation($"Email sent for message: {message.MessageId}");
        }
    }
}