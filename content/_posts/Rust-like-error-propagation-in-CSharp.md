---
title: Rust-like error propagation in C#
tags:
- fody-weaver
- IL
- .net
date: 2025-02-24
---

### Rust Result

I've been toying with Rust because I realised all I can do is write CRUD in C#. They have a really awesome [book](https://doc.rust-lang.org/book/) that you can read while you wait for your hello world program to compile. 

One sweet feature of rust is the way it handles error propagation, providing a handy `?` shortcut allowing you to give up when you encounter an error and let the calling code deal with all your problems. For example:

```rust
fn read_csv() -> Result<String, io::Error> {
    let mut file = File::open("upload.csv")?;
    // do something with the csv file
    Ok("yay we did it")
}
```

If `File::open` encounters an error, it will automatically return the error and exit the method early.

Results are a first class feature of Rust, intrinsic to it's design. C# doesn't have results (we have exceptions...) but we can easily build our own!

### C# Result

An incredibly basic result type:

```csharp
public class Result<T>
{
    public bool IsError { get; }
    public T Value { get; }
    public string? Error { get; }

    private Result(T value)
    {
        Value = value;
        IsError = false;
    }

    private Result(string error)
    {
        Error = error;
        IsError = true;
    }

    public static Result<T> Success(T value) => new(value);
    public static Result<T> Failure(string error) => new(error);
}
```

Let's try it out.

```csharp
public Result<int> GetNumber();

public Result<int> Operate() {
    var result = GetNumber();
	if (result.IsError) {
            return result;
	}

	var val = result.Value;
	var calculatedValue = val * 2;
	
	return Result<int>.Success(calculatedValue);
}
```

In this slightly contrived example we are getting a number, which may fail, then operating on it if it succeeds, returning the result early if it fails. But look how long it is! I've often toyed with using results, options, maybe etc. in C#, but handling them is either so verbose or you start trying to write "functional C#", which quickly looks absolutely ridiculous and every other C# developer who looks at your 9 chain deep function wants to cry. Libraries like [OneOf](https://github.com/mcintyre321/OneOf) are interesting and I've had some success with them in carefully chosen use cases.

But what if we could have what Rust has? 

### The idea: happy path only

We don't care about error checking, we just want to code the happy path! If we can somehow detect when our results are being unwrapped in C# and check if there was an error, returning it if there was, carrying on if not but without having to write a single `if` statement...

### Introducing the new C# interceptor feature!

Wait wait, I didn't read enough before I started writing interceptor code (and trusted Claude who confidently told me it was possible...). Interceptors can **intercept** a method call and replace it with another method call. And that is it, it is a very narrow, specific use case. We cant start adding arbitrary if statements and extra returns, mad stuff like that.

### Old is new again: Fody Weavers!

In my first job, fresh out of university, I had a senior developer who loved Fody Weavers and would tell anyone who listened how they were the future and everything would be sunshine and rainbows if we just could manipulate the IL a bit more. I had only learnt how to drink a lot at uni and didn't know what IL was, so I nodded sagely along and never thought about them again. 

But... maybe we could manipulate the IL?

First let's create a new solution and a `netstandard2.0` class library called `ResultWeaver.Fody`. The `.Fody` ending is important as it is how the weaver is loaded, apparently.

```xml
<Project Sdk="Microsoft.NET.Sdk">
	<PropertyGroup>
		<TargetFramework>netstandard2.0</TargetFramework>
	</PropertyGroup>

	<ItemGroup>
		<PackageReference Include="FodyHelpers" Version="6.9.1" />
	</ItemGroup>
</Project>
```

Each project can contain a single weaver, which we can define by creating a class that **must** be called `ModuleWeaver`. Let's start with something basic that just adds some console writing.

```csharp
using Mono.Cecil;
using Mono.Cecil.Cil;
using Fody;
using System.Collections.Generic;

namespace ResultWeaver.Fody
{
    public class ModuleWeaver : BaseModuleWeaver
    {
        public override void Execute()
        {
            // get all types in the module
            foreach (var type in ModuleDefinition.Types)
            {
                // process each method in the type
                foreach (var method in type.Methods)
                {
                    // only do this for methods containing "Hello"
                    if (!method.Name.Contains("Hello"))
                        continue;

                    // get the IL processor for the method
                    var il = method.Body.GetILProcessor();

                    // create the Console.WriteLine instruction
                    var writeLineRef = ModuleDefinition.ImportReference(
                        typeof(System.Console).GetMethod("Write",
                        new[] { typeof(string) }));

                    // write the name of the method
                    var loadString = il.Create(OpCodes.Ldstr, "Hello ");
                    var writeLineCall = il.Create(OpCodes.Call, writeLineRef);

                    // insert at the beginning of the method
                    il.InsertBefore(method.Body.Instructions[0], loadString);
                    il.InsertAfter(loadString, writeLineCall);
                }
            }
        }

        public override IEnumerable<string> GetAssembliesForScanning()
        {
            yield return "netstandard";
            yield return "mscorlib";
        }
    }
}
```

Every time I made a change to my weaver I had to delete the sample project's `bin` and `obj` folders. This powershell one-liner was handy.

```powershell
Get-ChildItem -Path . -Include bin,obj -Recurse | Remove-Item -Recurse -Force
```

Now we can add a little command line project to test our weaver, loading the weaver dll. We do not make a reference to the weaver project.

```xml
<Project Sdk="Microsoft.NET.Sdk">

  <PropertyGroup>
    <OutputType>Exe</OutputType>
    <TargetFramework>net8.0</TargetFramework>
    <ImplicitUsings>enable</ImplicitUsings>
    <Nullable>enable</Nullable>
  </PropertyGroup>

  <ItemGroup>
	  <PackageReference Include="Fody" Version="6.9.1">
		  <PrivateAssets>all</PrivateAssets>
		  <IncludeAssets>runtime; build; native; contentfiles; analyzers; buildtransitive</IncludeAssets>
	  </PackageReference>
	<WeaverFiles Include="$(SolutionDir)ResultWeaver.Fody\bin\$(Configuration)\netstandard2.0\ResultWeaver.Fody.dll" />
  </ItemGroup>

</Project>
```

Now we just need to tell our project to use the referenced weaver.

```xml
<?xml version="1.0" encoding="utf-8"?>
<Weavers xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="FodyWeavers.xsd">
  <ResultWeaver />
</Weavers>
```

Now we can test it with this simple program:

```csharp
Hello("world");

void Hello(string val) => Console.Write(val);
```

Without the weaver it will just print "world", with it will print "Hello world".

> If you every have any issues with your weaver not being loaded or being a general pain (which constantly happened to me...), try deleting all bin and obj folders and then rebuild the solution. Build order is important, you can right click the solution and make sure your weaver is built before any test project.

But what is it actually doing? You can grab [ILSpy](https://github.com/icsharpcode/ILSpy/releases) (which has a handy VS extension too) and view the C#, IL and best, the IL + C# generated by your project + weaver.

### Weaving in error checks

So let's add a method `OrReturn` to our result that will unwrap the value and allow us to detect where we want to start messing around.

```csharp
public T OrReturn()
{
	throw new InvalidOperationException("This should be replaced by the weaver");
}
```

Feeling confident, let's not even bother implementing anything! What we are aiming for is that this:

```csharp
public Result<int> MultiplyBy2() { 
	var result = GetNumber().OrReturn();
	return Result<int>.Success(result * 2); 
}
```

Will be weaved into this:

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

With a little bit of copy paste from various open source weavers, having to read what the hell a stack height is, all with too much trial and error, let's see what we've got.

```csharp
using Mono.Cecil;
using Mono.Cecil.Cil;
using Mono.Cecil.Rocks;
using Fody;
using System.Collections.Generic;
using System.Linq;

namespace ResultWeaver.Fody
{
    public class ModuleWeaver : BaseModuleWeaver
    {
        public override void Execute()
        {
            foreach (var type in ModuleDefinition.Types)
            {
                ProcessType(type);
            }
        }

        private void ProcessType(TypeDefinition type)
        {
            foreach (var method in type.Methods)
            {
                if (!method.HasBody)
                    continue;

                method.Body.SimplifyMacros();

                var instructions = method.Body.Instructions;
                var processor = method.Body.GetILProcessor();

                for (var i = 0; i < instructions.Count; i++)
                {
                    var instruction = instructions[i];

                    // this should probably check something more than just the method name...
                    if (instruction.OpCode != OpCodes.Callvirt
                        || !(instruction.Operand is MethodReference calledMethod)
                        || calledMethod.Name != "OrReturn")
                        continue;

                    var genericResultType = (GenericInstanceType)calledMethod.DeclaringType;
                    var resultDefinition = genericResultType.ElementType.Resolve();

                    var isErrorGetter = ModuleDefinition.ImportReference(
                        resultDefinition.Properties.Single(p => p.Name == "IsError").GetMethod);
                    var valueGetter = ModuleDefinition.ImportReference(
                        resultDefinition.Properties.Single(p => p.Name == "Value").GetMethod);

                    isErrorGetter = MakeGeneric(isErrorGetter, genericResultType);
                    valueGetter = MakeGeneric(valueGetter, genericResultType);

                    var tempLocal = new VariableDefinition(genericResultType);
                    method.Body.Variables.Add(tempLocal);

                    // find or create the result local variable (for the early return)
                    var resultLocal = method.Body.Variables.FirstOrDefault(v =>
                        v.VariableType.FullName == genericResultType.FullName &&
                        v != tempLocal);

                    if (resultLocal == null)
                    {
                        resultLocal = new VariableDefinition(genericResultType);
                        method.Body.Variables.Add(resultLocal);
                    }

                    // find the end of the try/catch block if in one
                    Instruction endLeave = null;

                    // first find the end target of the try block (where the original leave instruction goes to)
                    var tryHandler = method.Body.ExceptionHandlers.FirstOrDefault(h =>
                        IsInstructionInRange(instruction, h.TryStart, h.TryEnd));

                    if (tryHandler != null)
                    {
                        // find the existing leave instruction's target
                        var existingLeave = method.Body.Instructions
                            .FirstOrDefault(x =>
                                (x.OpCode == OpCodes.Leave || x.OpCode == OpCodes.Leave_S) &&
                                x.Offset >= tryHandler.TryStart.Offset &&
                                x.Offset <= tryHandler.TryEnd.Offset);

                        // get the target instruction that the original leave points to
                        endLeave = existingLeave?.Operand as Instruction;
                    }

                    var afterIf = processor.Create(OpCodes.Nop);

                    // Store the result into temp
                    processor.InsertBefore(instruction, processor.Create(OpCodes.Stloc, tempLocal));

                    // Load temp and check IsError
                    processor.InsertBefore(instruction, processor.Create(OpCodes.Ldloc, tempLocal));
                    processor.InsertBefore(instruction, processor.Create(OpCodes.Callvirt, isErrorGetter));
                    processor.InsertBefore(instruction, processor.Create(OpCodes.Brfalse, afterIf));

                    if (endLeave == null)
                    {
                        // we're not in a try catch so we can just return
                        processor.InsertBefore(instruction, processor.Create(OpCodes.Ldloc, tempLocal));
                        processor.InsertBefore(instruction, processor.Create(OpCodes.Ret));
                    }
                    else
                    {
                        // If error, store temp in result and leave (don't return!)
                        processor.InsertBefore(instruction, processor.Create(OpCodes.Ldloc, tempLocal));
                        processor.InsertBefore(instruction, processor.Create(OpCodes.Stloc, resultLocal));
                        // Insert custom leave instruction pointing to the existing leave instruction
                        processor.InsertBefore(instruction,
                            processor.Create(OpCodes.Leave, endLeave));
                    }

                    // after the if get the value from the result
                    processor.InsertBefore(instruction, afterIf);
                    processor.InsertBefore(instruction, processor.Create(OpCodes.Ldloc, tempLocal));
                    processor.InsertBefore(instruction, processor.Create(OpCodes.Callvirt, valueGetter));

                    processor.Remove(instruction);
                    i--;
                }

                method.Body.OptimizeMacros();
            }
        }

        private MethodReference MakeGeneric(MethodReference method, GenericInstanceType genericType)
        {
            var reference = new MethodReference(method.Name, method.ReturnType, genericType)
            {
                HasThis = true,
                ExplicitThis = method.ExplicitThis,
                CallingConvention = method.CallingConvention,
            };

            foreach (var parameter in method.Parameters)
                reference.Parameters.Add(new ParameterDefinition(parameter.ParameterType));

            return reference;
        }

        private bool IsInstructionInRange(Instruction instruction, Instruction start, Instruction end)
        {
            return instruction.Offset >= start.Offset && instruction.Offset < end.Offset;
        }

        public override IEnumerable<string> GetAssembliesForScanning()
        {
            yield return "netstandard";
            yield return "mscorlib";
        }
    }
}
```

Phew, that is a lot of code. It is actually pretty simple, a little verbose. But it works!

Given the following program:

```csharp
var result = Multiply();

if (result.IsError)
    Console.WriteLine("Error: " + result.Error);
else
    Console.WriteLine("Success: " + result.Value);

Result<int> Multiply()
{
    Console.WriteLine("Starting");

    try
    {
        var first = GetSuccess().OrReturn();
        Console.WriteLine("Got first value: " + first);

        var val = GetFail().OrReturn();
        Console.WriteLine("Got second value: " + val);

        Console.WriteLine("Multiplying");
        return Result<int>.Success(first * val);
    }
    catch
    {
        return Result<int>.Failure("exception");
    }
}

Result<int> GetFail() => Result<int>.Failure("result failure");

Result<int> GetSuccess() => Result<int>.Success(12);
```

We see the following printed in the console:

```
Starting
Got first value: 12
Error: result failure
```

And we can confirm it is working by peeking at the new C# our modified IL represents:

```csharp
static Result<int> Multiply()
{
	Console.WriteLine("Starting");
	try
	{
		Result<int> result2 = GetSuccess();
		if (result2.IsError)
		{
			return result2;
		}
		int first = result2.Value;
		Console.WriteLine("Got first value: " + first);
		Result<int> result3 = GetFail();
		if (result3.IsError)
		{
			return result3;
		}
		int val = result3.Value;
		Console.WriteLine("Got second value: " + val);
		Console.WriteLine("Multiplying");
		return Result<int>.Success(first * val);
	}
	catch
	{
		return Result<int>.Failure("exception");
	}
}
```

But what it demonstrates most clearly is that this is a rabbit hole of issues waiting to be found. I handled the scenario where the `OrReturn` is in a `try`. But what about a `catch`? Nested `try catch`? `async` code. Expression-bodied members. Using statements and disposal patterns. Nested scopes (e.g. local functions). Pattern matching or switch statements. Generic methods and covariance/contravariance scenarios. What if they try to do `GetOne().OrReturn() + GetTwo().OrReturn()`?! The list goes on and on...

And what if someone chains multiple methods together? We probably need an analyzer to go with this to stop naughty developers toppling our fody weaved tower of cards.

We'd also want to improve our `Result` to be able to map one type of result to another, though at least we don't have to touch IL for that!

Okay this is all getting a bit out of hand. This was a fun if pointless experiment, but was a nice reminder of how mature tooling around C# is and the strange, wonderful things we can do with it.

