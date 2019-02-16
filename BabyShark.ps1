$basePath = $PWD.Path
if (Test-Path "$basePath\BabyShark.exe") {
    Remove-Item "$basePath\BabyShark.exe"
    Remove-Item "$basePath\BabyShark.pdb"
}

$assemblyName = new-object System.Reflection.AssemblyName
$assemblyName.Name = "BabyShark"
$assemblyBuilder = [System.AppDomain]::CurrentDomain.DefineDynamicAssembly($assemblyName, [System.Reflection.Emit.AssemblyBuilderAccess]::RunAndSave, $basePath)
$moduleBuilder = $assemblyBuilder.DefineDynamicModule("BabyShark.exe", "BabyShark.exe", $true)
$typeBuilder = $moduleBuilder.DefineType("Program", [System.Reflection.TypeAttributes]::Public -bor [System.Reflection.TypeAttributes]::Class)
$method = $typeBuilder.DefineMethod("Main", [System.Reflection.MethodAttributes]::Public -bor [System.Reflection.MethodAttributes]::Static)

$il = $method.GetILGenerator()

$family = @("Baby", "Daddy", "Mommy", "Grandpa", "Grandma")
$doos = [string]::Join(" ", ((1..6) | % { "doo" }))

function Get-OpCode($name) {
    $field = [System.Reflection.Emit.OpCodes].GetField($name, [System.Reflection.BindingFlags]::Static -bor [System.Reflection.BindingFlags]::Public)

    if (-not $field) {
        return $null
    }

    return $field.GetValue($null)
}

function Emit-IL($name, $value) {
    if ($name -eq "Stloc_S") {
        if ($value -le 3) {
            $name = "Stloc_$value"
            $value = $null 
        }
    }

    if ($name -eq "Ldloc_S") {
        if ($value -le 3) {
            $name = "Ldloc_$value"
            $value = $null 
        }
    }

    if ($name -eq "Ldc_I4_S") {
        if ($value -le 8) {
            $name = "Ldc_I4_$value"
            $value = $null 
        }
    }

    $code = Get-OpCode $name
    if ($value -eq $null) {
        $il.Emit($code)
    } else {
        $il.Emit($code, $value)
    }
}

$il.Emit([System.Reflection.Emit.OpCodes]::Nop)

# create new "family" variable and initialize it
$familyLocal = $il.DeclareLocal([string[]])
$familyLocal.SetLocalSymInfo("family")
Emit-IL "Ldc_I4_S" $family.Length
$il.Emit([System.Reflection.Emit.OpCodes]::Newarr, [string])
for ($i = 0; $i -lt $family.Length; $i++) {
    $il.Emit([System.Reflection.Emit.OpCodes]::Dup)
    Emit-IL "Ldc_I4_S" $i
    $il.Emit([System.Reflection.Emit.OpCodes]::Ldstr, $family[$i])
    $il.Emit([System.Reflection.Emit.OpCodes]::Stelem_Ref)
}
Emit-IL "Stloc_S" $familyLocal.LocalIndex

# setup "doos" variable and iniitalize
$doosLocal = $il.DeclareLocal([string])
$doosLocal.SetLocalSymInfo("doos")
$il.Emit([System.Reflection.Emit.OpCodes]::Ldstr, $doos)
Emit-IL "Stloc_S" $doosLocal.LocalIndex

$il.Emit([System.Reflection.Emit.OpCodes]::Nop)

function Write-ForEach($sourceLocal, $itemName, $body) {
    #init foreach
    $label0 = $il.DefineLabel()
    $label1 = $il.DefineLabel()

    $sourceCopy = $il.DeclareLocal([string[]])
    Emit-IL "LdLoc_S" $sourceLocal.LocalIndex
    Emit-IL "Stloc_S" $sourceCopy.LocalIndex

    $indexLocal = $il.DeclareLocal([int])
    $itemLocal = $il.DeclareLocal([string])
    $itemLocal.SetLocalSymInfo($itemName)

    Emit-IL "Ldc_I4_0"
    Emit-IL "Stloc_S" $indexLocal.LocalIndex
    $il.Emit([System.Reflection.Emit.OpCodes]::Br_S, $label1)

    $il.MarkLabel($label0)
    Emit-IL "LdLoc_S" $sourceCopy.LocalIndex
    Emit-IL "LdLoc_S" $indexLocal.LocalIndex
    $il.Emit([System.Reflection.Emit.OpCodes]::Ldelem_Ref)
    Emit-IL "Stloc_S" $itemLocal.LocalIndex

    # no op
    $body.Invoke($itemLocal)
    # no op

    Emit-IL "LdLoc_S" $indexLocal.LocalIndex
    $il.Emit([System.Reflection.Emit.OpCodes]::Ldc_I4_1)
    $il.Emit([System.Reflection.Emit.OpCodes]::Add)
    Emit-IL "Stloc_S" $indexLocal.LocalIndex

    $il.MarkLabel($label1)
    Emit-IL "LdLoc_S" $indexLocal.LocalIndex
    Emit-IL "LdLoc_S" $sourceCopy.LocalIndex
    $il.Emit([System.Reflection.Emit.OpCodes]::Ldlen)
    $il.Emit([System.Reflection.Emit.OpCodes]::Conv_I4)
    $il.Emit([System.Reflection.Emit.OpCodes]::Blt_S, $label0)
}

function Write-For($start, $end, $body) {
    $indexLocal = $il.DeclareLocal([int])
    $indexLocal.SetLocalSymInfo("i")
    $loopLocal = $il.DeclareLocal([bool])
    $label0 = $il.DefineLabel()
    $label1 = $il.DefineLabel()

    Emit-IL "Ldc_I4_S" $start
    Emit-IL "Stloc_S" $indexLocal.LocalIndex
    Emit-IL "Br_S" $label1

    $il.MarkLabel($label0)
    Emit-IL "Nop"

    $body.Invoke()

    Emit-IL "Ldloc_S" $indexLocal.LocalIndex
    Emit-IL "Ldc_I4_1"
    Emit-IL "Add"
    Emit-IL "Stloc_S" $indexLocal.LocalIndex

    $il.MarkLabel($label1)
    Emit-IL "Ldloc_S" $indexLocal.LocalIndex
    Emit-IL "Ldc_I4_S" ($end + 1)
    Emit-IL "Clt"
    Emit-IL "Stloc_S" $loopLocal.LocalIndex
    Emit-IL "Ldloc_S" $loopLocal.LocalIndex
    Emit-IL "Brtrue_S" $label0
}

[Type[]]$singleString = @([string])
[Type[]]$twoStrings = @([string],[string])
[Type[]]$threeStrings = @([string],[string],[string])


Write-ForEach $familyLocal "member" { 
    param ($item)


    Write-For 1 3 {
        Emit-IL "Ldloc_S" $item.LocalIndex
        Emit-IL "Ldstr" " shark "
        Emit-IL "Ldloc_S" $doosLocal.LocalIndex
        $il.EmitCall([System.Reflection.Emit.OpCodes]::Call, [string].GetMethod("Concat", $threeStrings), $threeStrings)
        $il.EmitCall([System.Reflection.Emit.OpCodes]::Call, [System.Console].GetMethod("WriteLine", $singleString), $singleString)
    }

    Emit-IL "Ldloc_S" $item.LocalIndex
    Emit-IL "Ldstr" " shark!"
    $il.EmitCall([System.Reflection.Emit.OpCodes]::Call, [string].GetMethod("Concat", $twoStrings), $twoStrings)
    $il.EmitCall([System.Reflection.Emit.OpCodes]::Call, [System.Console].GetMethod("WriteLine", $singleString), $singleString)
}

$il.Emit([System.Reflection.Emit.OpCodes]::Ret)

$typeBuilder.CreateType() | Out-Null

$assemblyBuilder.SetEntryPoint($method, [System.Reflection.Emit.PEFileKinds]::ConsoleApplication);
$assemblyBuilder.Save("BabyShark.exe")

$ildasm = "C:\Program Files (x86)\Microsoft SDKs\Windows\v10.0A\bin\NETFX 4.6.1 Tools\ildasm.exe"

& $ildasm /text /item:Program::Main /source "$basePath\BabyShark.exe"

ilspycmd "$basePath\BabyShark.exe"

& "$basePath\BabyShark.exe"
