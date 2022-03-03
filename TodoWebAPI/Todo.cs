﻿using System.ComponentModel.DataAnnotations;
using System.Text.Json.Serialization;

namespace TodoWebAPI;

public class Todo
{
    [JsonPropertyName("_id")]
    [Key]
    public string Id { get; set; }
    public string Task { get; init; }
    public bool Completed { get; set; }
    public override string ToString()
    {
        return $"TaskId: {Id}, Text: {Task}";
    }

    public void Deconstruct(out string Id, out string Task, out bool Completed)
    {
        Id = this.Id;
        Task = this.Task;
        Completed = this.Completed;
    }
}