using System.Net.Http.Json;
using System.Text.Json;
using System.Text.Json.Serialization;
using TodoUI.Models;

namespace TodoUI.Services;

public class TodoService
{
    private readonly ILogger<TodoService> logger;
    private readonly HttpClient httpClient;

    public TodoService(IHttpClientFactory httpClientFactory, ILogger<TodoService> logger)
    {
        this.logger = logger;
        this.httpClient = httpClientFactory.CreateClient("TodoApi");
    }

    public async Task<Todo[]> GetAllTodos()
    {
        var requestUri = "api/todos";
        logger.LogInformation($"Getting list of todos from {new Uri(httpClient.BaseAddress, requestUri)}");
        return await httpClient.GetFromJsonAsync<Todo[]>(requestUri);
    }

    public async Task ChangeStatus(string todoId, bool isCompleted)
    {
        var requestUri = $"api/todos/{todoId}";
        logger.LogInformation($"Changing status of TODO {todoId} to {(isCompleted ? "completed" : "not completed")}");
        var response = await httpClient.PutAsJsonAsync(requestUri, new {Completed = isCompleted });
        if (!response.IsSuccessStatusCode)
        {
            throw new Exception(response.StatusCode.ToString());
        }
    }

    public async Task Delete(string todoId)
    {
        var requestUri = $"api/todos/{todoId}";
        logger.LogInformation($"Deleting TODO with id: {todoId}");
        var response = await httpClient.DeleteAsync(requestUri);
        if (!response.IsSuccessStatusCode)
        {
            throw new Exception(response.StatusCode.ToString());
        }
    }

    public async Task<Todo> CreateNewByName(string taskName)
    {
        var requestUri = $"api/todos";
        var newTodo = new { Completed = false, Task = taskName};
        var response = await httpClient.PostAsJsonAsync(requestUri, newTodo);
        if (!response.IsSuccessStatusCode)
        {
            throw new Exception(response.StatusCode.ToString());
        }
        var id = (await response.Content.ReadFromJsonAsync<CreateResponse>()).Id;

        return new Todo(){Completed = newTodo.Completed, Task = newTodo.Task, Id = id};
    }

    record CreateResponse(string Id);
}

