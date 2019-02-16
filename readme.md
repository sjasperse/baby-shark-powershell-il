# Baby Shark with Powershell via dynamically generated .NET IL

I was feeling masochistic one night... so I spent hours of my life I'll never get back coming up with this debacle.

I did not start the night knowing much about IL, so it took far more time than I had any reason to put into it.

## Output
```
Baby shark doo doo doo doo doo doo
Baby shark doo doo doo doo doo doo
Baby shark doo doo doo doo doo doo
Baby shark!
Daddy shark doo doo doo doo doo doo
Daddy shark doo doo doo doo doo doo
Daddy shark doo doo doo doo doo doo
Daddy shark!
Mommy shark doo doo doo doo doo doo
Mommy shark doo doo doo doo doo doo
Mommy shark doo doo doo doo doo doo
Mommy shark!
Grandpa shark doo doo doo doo doo doo
Grandpa shark doo doo doo doo doo doo
Grandpa shark doo doo doo doo doo doo
Grandpa shark!
Grandma shark doo doo doo doo doo doo
Grandma shark doo doo doo doo doo doo
Grandma shark doo doo doo doo doo doo
Grandma shark!
```

## Generated code
Generated from the `.exe` via [`ilspycmd` link.](https://github.com/icsharpcode/ILSpy/tree/master/ICSharpCode.Decompiler.Console)
```
using System;
using System.Reflection;

[assembly: AssemblyVersion("0.0.0.0")]
public class Program
{
        public static void Main()
        {
                string[] array = new string[5]
                {
                        "Baby",
                        "Daddy",
                        "Mommy",
                        "Grandpa",
                        "Grandma"
                };
                string str = "doo doo doo doo doo doo";
                string[] array2 = array;
                foreach (string str2 in array2)
                {
                        for (int j = 1; j < 4; j++)
                        {
                                Console.WriteLine(str2 + " shark " + str);
                        }
                        Console.WriteLine(str2 + " shark!");
                }
        }
}
```

## Generated IL
Why are you even looking at this?
```
.class public auto ansi Program
       extends [mscorlib]System.Object
{
  .method public static void  Main() cil managed
  {
    .entrypoint
    // Code size       162 (0xa2)
    .maxstack  9
    .locals init ([0] string[] 'family',
             [1] string doos,
             [2] string[] V_2,
             [3] int32 V_3,
             [4] string member,
             [5] int32 i,
             [6] bool V_6)
    IL_0000:  nop
    IL_0001:  ldc.i4.5
    IL_0002:  newarr     [mscorlib]System.String
    IL_0007:  dup
    IL_0008:  ldc.i4.0
    IL_0009:  ldstr      "Baby"
    IL_000e:  stelem.ref
    IL_000f:  dup
    IL_0010:  ldc.i4.1
    IL_0011:  ldstr      "Daddy"
    IL_0016:  stelem.ref
    IL_0017:  dup
    IL_0018:  ldc.i4.2
    IL_0019:  ldstr      "Mommy"
    IL_001e:  stelem.ref
    IL_001f:  dup
    IL_0020:  ldc.i4.3
    IL_0021:  ldstr      "Grandpa"
    IL_0026:  stelem.ref
    IL_0027:  dup
    IL_0028:  ldc.i4.4
    IL_0029:  ldstr      "Grandma"
    IL_002e:  stelem.ref
    IL_002f:  stloc.0
    IL_0030:  ldstr      "doo doo doo doo doo doo"
    IL_0035:  stloc.1
    IL_0036:  nop
    IL_0037:  ldloc.0
    IL_0038:  stloc.2
    IL_0039:  ldc.i4.0
    IL_003a:  stloc.3
    IL_003b:  br.s       IL_009b

    IL_003d:  ldloc.2
    IL_003e:  ldloc.3
    IL_003f:  ldelem.ref
    IL_0040:  stloc.s    member
    IL_0042:  nop
    IL_0043:  nop
    IL_0044:  nop
    IL_0045:  ldc.i4.1
    IL_0046:  stloc.s    i
    IL_0048:  nop
    IL_0049:  nop
    IL_004a:  nop
    IL_004b:  br.s       IL_006f

    IL_004d:  nop
    IL_004e:  ldloc.s    member
    IL_0050:  nop
    IL_0051:  nop
    IL_0052:  nop
    IL_0053:  ldstr      " shark "
    IL_0058:  ldloc.1
    IL_0059:  call       string [mscorlib]System.String::Concat(string,
                                                                string,
                                                                string)
    IL_005e:  call       void [mscorlib]System.Console::WriteLine(string)
    IL_0063:  ldloc.s    i
    IL_0065:  nop
    IL_0066:  nop
    IL_0067:  nop
    IL_0068:  ldc.i4.1
    IL_0069:  add
    IL_006a:  stloc.s    i
    IL_006c:  nop
    IL_006d:  nop
    IL_006e:  nop
    IL_006f:  ldloc.s    i
    IL_0071:  nop
    IL_0072:  nop
    IL_0073:  nop
    IL_0074:  ldc.i4.4
    IL_0075:  clt
    IL_0077:  stloc.s    V_6
    IL_0079:  nop
    IL_007a:  nop
    IL_007b:  nop
    IL_007c:  ldloc.s    V_6
    IL_007e:  nop
    IL_007f:  nop
    IL_0080:  nop
    IL_0081:  brtrue.s   IL_004d

    IL_0083:  ldloc.s    member
    IL_0085:  nop
    IL_0086:  nop
    IL_0087:  nop
    IL_0088:  ldstr      " shark!"
    IL_008d:  call       string [mscorlib]System.String::Concat(string,
                                                                string)
    IL_0092:  call       void [mscorlib]System.Console::WriteLine(string)
    IL_0097:  ldloc.3
    IL_0098:  ldc.i4.1
    IL_0099:  add
    IL_009a:  stloc.3
    IL_009b:  ldloc.3
    IL_009c:  ldloc.2
    IL_009d:  ldlen
    IL_009e:  conv.i4
    IL_009f:  blt.s      IL_003d

    IL_00a1:  ret
  } // end of method Program::Main

} // end of class Program
```