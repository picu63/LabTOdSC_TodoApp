using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using TodoWebAPI.Database;


namespace TodoWebAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class TodosController : ControllerBase
    {

        private readonly ILogger<TodosController> _logger;
        private readonly TodosDbContext todosDbContext;

        public TodosController(ILogger<TodosController> logger, TodosDbContext todosDbContext)
        {
            _logger = logger;
            this.todosDbContext = todosDbContext;
        }

        [HttpGet(Name = "GetAllTodos")]
        public async Task<ActionResult<IEnumerable<Todo>>> Get()
        {
            return Ok(await todosDbContext.Todos.ToListAsync());
        }

        [HttpDelete("{id}",Name = "DeleteTodo")]
        public async Task<ActionResult> Delete(string id)
        {
            var todoToDelete = await todosDbContext.Todos.SingleOrDefaultAsync(t => t.Id == id);
            if (todoToDelete is null) return NotFound($"Not found object with id: {id}");
            todosDbContext.Todos.Remove(todoToDelete);
            await todosDbContext.SaveChangesAsync();
            return Ok($"Object with id: {id} was deleted");
        }

        [HttpPut("{id}",Name = "ChangeCompletionStatus")]
        public async Task<ActionResult> CompletionUpdate(string id, [FromBody] bool completed)
        {
            var todo = await todosDbContext.Todos.SingleOrDefaultAsync(t => t.Id == id);
            if (todo is null)
            {
                return BadRequest($"There is no todo item with id: {id}");
            }

            todo.Completed = completed;
            await todosDbContext.SaveChangesAsync();
            return Ok($"Changed status of todo item with id: {id} to {(completed ? "Completed" : "Not Completed")}");
        }

        [HttpPost]
        public async Task<ActionResult> Create([FromBody]string todoName)
        {
            var todo = new Todo() { Task = todoName, Completed = false, Id = Guid.NewGuid().ToString() };
            await todosDbContext.Todos.AddAsync(todo);
            await todosDbContext.SaveChangesAsync();
            return Ok(todo);
        }
    }
}