$assemblyName = new-object System.Reflection.AssemblyName
$assemblyName.Name = "BabyShark"
$assemblyBuilder = [System.AppDomain]::CurrentDomain.DefineDynamicAssembly($assemblyName, [System.Reflection.Emit.AssemblyBuilderAccess]::Run)
$module = $assemblyBuilder.DefineDynamicModule($assemblyName.Name)
$typeBuilder = $module.DefineType("Program", [System.Reflection.TypeAttributes]::Public -bor [System.Reflection.TypeAttributes]::Class)
$methodBuilder = $typeBuilder.DefineMethod("Main", [System.Reflection.MethodAttributes]::Public)
$ilGen = $methodBuilder.GetILGenerator()
$ilGen.EmitWriteLine("Hello, World!")
#$ilGen.Emit([System.Reflection.Emit.OpCodes]::Ldstr, "Hello, World!")
#$ilGen.Emit([System.Reflection.Emit.OpCodes]::Call, [System.Console].GetMethod("WriteLine", @( [string] )))

$type = $typeBuilder.CreateType()

$instance = [System.Activator]::CreateInstance($type)
$instance.Main()