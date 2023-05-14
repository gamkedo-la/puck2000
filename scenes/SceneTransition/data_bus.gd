extends Node

var selections:Dictionary = {}

func test_func(data:Dictionary) -> void:
	selections = data
	prints("boop", selections["table"].instance().name)

