---
title: Abusing await with a result type to achieve rust-like error propagation in C#
tags:
- await
- c#
- .net
date: 2025-02-26
---

Rust allows you to [propagate errors](https://doc.rust-lang.org/book/ch09-02-recoverable-errors-with-result.html?highlight=error%20propagat#propagating-errors) automatically with the `?` keyword, short-circuiting the method's execution and returning the error.

Previously, we attempted to [modify the IL to propagate errors with Fody](/rust-like-error-propagation-in-csharp), turning this:

```csharp
public Result<int> MultiplyBy2() { 
	var result = GetNumber().OrReturn();
	return Result<int>.Success(result * 2); 
}
```

Into this:

```csharp
public Result<int> MultiplyBy2() { 
	var temp = GetNumber();
	if (temp.IsError) {
		return temp;
	}
	var result = temp.Value; 
	return Result<int>.Success(result * 2); 
}
```

It worked! Sort of, turns out C# is complex and trying to modify the IL will be rabbit hole we may never escape from. but is there a way we can have the compiler deal with all the complexity for us? A friend pointed out another even more bonkers idea.

### await there one second...

The `await` operator suspends execution of the enclosing function until the asynchronous operation is completed. To do this under the hood it generates a state machine. I'm not going to begin to try to explain this because 1) I don't know enough, 2) [Stephen Toub exists](https://devblogs.microsoft.com/dotnet/how-async-await-really-works/).

What we will end up with is this:

```csharp
Result<double> Parse(string input) =>
    Result.Try(() => double.Parse(input));

Result<double> Divide(double x, double y) =>
    Result.Try(() => x / y);

async Result<double> Do(string a, string b)
{
    var x = await Parse(a);
    var y = await Parse(b);
    Console.WriteLine("Successfully parsed inputs");
    return await Divide(x, y);
}

// Usage
Console.WriteLine(Do("2", "b"));  // Will display the error from Parse("b")
```

The key to achieving this is that we can control how that state machine behaves by creating a custom `AsyncMethodBuilder`, allowing us to short-circuit the method execution when it encounters an error result.

```csharp
[AsyncMethodBuilder(typeof(ResultAsyncMethodBuilder<>))]
public struct Result<T> {}
```

The full code:

```csharp
[AsyncMethodBuilder(typeof(ResultAsyncMethodBuilder<>))]
public struct Result<T>
{
    private Result(T value)
    {
        IsSuccess = true;
        Value = value;
        Error = null;
    }

    private Result(Exception error)
    {
        IsSuccess = false;
        Value = default;
        Error = error;
    }

    [MemberNotNullWhen(true, nameof(Value))]
    [MemberNotNullWhen(false, nameof(Error))]
    public bool IsSuccess { get; }
    public T? Value { get; }
    public Exception? Error { get; }

    public static Result<T> Success(T value) => new(value);
    public static Result<T> Fail(Exception error) => new(error);

    public static implicit operator Result<T>(T value) => Success(value);

    public ResultAwaiter<T> GetAwaiter() => new ResultAwaiter<T>(this);

    public override string ToString() => IsSuccess ? Value?.ToString() : $"Error: {Error?.Message}";
}

public static class Result
{
    public static Result<T> Try<T>(Func<T> function)
    {
        try
        {
            return Result<T>.Success(function());
        }
        catch (Exception ex)
        {
            return Result<T>.Fail(ex);
        }
    }
}

public struct ResultAwaiter<T> : ICriticalNotifyCompletion
{
    private readonly Result<T> _result;

    public ResultAwaiter(Result<T> result)
    {
        _result = result;
    }

    public bool IsCompleted => true;

    public T GetResult()
    {
        if (!_result.IsSuccess)
            ResultAsyncMethodBuilder<T>.SetError(_result.Error);

        return _result.IsSuccess ? _result.Value : default;
    }

    public void OnCompleted(Action continuation) => continuation();
    public void UnsafeOnCompleted(Action continuation) => continuation();
}

public struct ResultAsyncMethodBuilder<T>
{
    private Result<T> _result;
    private Exception _exception;

    public static ResultAsyncMethodBuilder<T> Create() =>
        new ResultAsyncMethodBuilder<T>();

    public void Start<TStateMachine>(ref TStateMachine stateMachine)
        where TStateMachine : IAsyncStateMachine 
        => stateMachine.MoveNext();

    public void SetResult(T result)
        => _result = Result<T>.Success(result);

    public void SetException(Exception exception)
    {
        _exception = exception;
        _result = Result<T>.Fail(exception);
    }

    public void AwaitOnCompleted<TAwaiter, TStateMachine>(
        ref TAwaiter awaiter,
        ref TStateMachine stateMachine)
        where TAwaiter : INotifyCompletion
        where TStateMachine : IAsyncStateMachine
    {
        var completionAction = CreateCompletionAction(ref stateMachine);
        awaiter.OnCompleted(completionAction);
    }

    public void AwaitUnsafeOnCompleted<TAwaiter, TStateMachine>(
        ref TAwaiter awaiter,
        ref TStateMachine stateMachine)
        where TAwaiter : ICriticalNotifyCompletion
        where TStateMachine : IAsyncStateMachine
    {
        var completionAction = CreateCompletionAction(ref stateMachine);
        awaiter.UnsafeOnCompleted(completionAction);
    }

    public void SetStateMachine(IAsyncStateMachine stateMachine) { }

    public static void SetError(Exception exception)
        => throw new ResultException(exception);

    public Result<T> Task
    {
        get
        {
            if (_exception is ResultException resultException)
                return Result<T>.Fail(resultException.InnerException);

            return _result;
        }
    }

    private Action CreateCompletionAction<TStateMachine>(
        ref TStateMachine stateMachine)
        where TStateMachine : IAsyncStateMachine
    {
        var boxedStateMachine = stateMachine;
        return boxedStateMachine.MoveNext;
    }

    private class ResultException : Exception
    {
        public ResultException(Exception innerException)
            : base("Result operation failed", innerException) { }
    }
}
```

When we `await someResult`, the compiler generates code that calls `GetAwaiter()` on the `Result<T>`, returning our special `ResultAwaiter<T>`.

In the `ResultAwaiter<T>.GetResult()` method we check if there was an error:

```csharp
if (!_result.IsSuccess)
    ResultAsyncMethodBuilder<T>.SetError(_result.Error);
```

So when we await a `Result<T>` that is an error we set this error on the builder instead of throwing the exception directly.

Then we throw an exception! Wait, weren't we trying to get rid of exceptions... Whatever, it is a special exception! The state machine will then tell our a builder that an exception has happened and we store that exception plus a failed result.

```csharp
public void SetException(Exception exception)
{
    _exception = exception;
    _result = Result<T>.Fail(exception);
}
```

Now how do we get all this out? Our builder has the `Task` property which is used by the state machine to get the final value. We have special handling here to return an error result if there was a `ResultException` thrown.

```csharp
public Result<T> Task
{
    get
    {
        if (_exception is ResultException resultException)
            return Result<T>.Fail(resultException.InnerException);

        return _result;
    }
}
```

And that is basically what creates the short-circuit: when an error `Result<T>` is awaited, the execution of the async method is just  stopped at that point, with the method returning a failed `Result<T>` containing the original exception instead of throwing an exception to the caller.

### Running it

If we run this we should see this in the console:

```
Error: The input string 'b' was not in a correct format.
```

So it didn't reach the log saying the inputs were parsed. Now if we change our program to run:

```csharp
Console.WriteLine(Do("4", "2"));
```

Now we see:

```
Successfully parsed inputs
2
```

### Wrapping up

Obviously, don't do this. It is wildly abusing `await` and just plain madness! But it is fun to learn and I understand a little bit more about how async and await are achieved in C#.

Big thanks to Kostia for reading my [previous post](/rust-like-error-propagation-in-csharp) and pointing me in the direction of more crazy things to play with.

Here is a link to a repo with all the code: [https://github.com/Hazzamanic/AwaitableResult](https://github.com/Hazzamanic/AwaitableResult).