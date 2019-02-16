clear
$ErrorActionPreference = "Stop"
$basePath = $PWD.Path
if (Test-Path "$basePath\BabyShark.exe") {
    Remove-Item "$basePath\BabyShark.exe"
    Remove-Item "$basePath\BabyShark.pdb"
    Write-Host "Removed old files"
}

$assemblyName = new-object System.Reflection.AssemblyName
$assemblyName.Name = "BabyShark"
$assemblyBuilder = [System.AppDomain]::CurrentDomain.DefineDynamicAssembly($assemblyName, [System.Reflection.Emit.AssemblyBuilderAccess]::RunAndSave, $basePath)
$moduleBuilder = $assemblyBuilder.DefineDynamicModule("BabyShark.exe", "BabyShark.exe", $true)
$typeBuilder = $moduleBuilder.DefineType("Program", [System.Reflection.TypeAttributes]::Public -bor [System.Reflection.TypeAttributes]::Class)
$method = $typeBuilder.DefineMethod("Main", [System.Reflection.MethodAttributes]::Public -bor [System.Reflection.MethodAttributes]::Static)

$il = $method.GetILGenerator()
$il.EmitWriteLine([DateTime]::Now.ToShortTimeString())

$family = @("Baby", "Daddy", "Mommy", "Grandpa", "Grandma")
$doos = [string]::Join(" ", ((1..6) | % { "doo" }))
# foreach ($member in $family) {
#     (1..3) | % { $il.EmitWriteLine("$member shark $([string]::Join(" ", $dos))") }
#     $il.EmitWriteLine("$member shark!")
# }

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

function Write-ForEach($sourceLocal, $itemName) {
    #init foreach
    $label0 = $il.DefineLabel()
    $label1 = $il.DefineLabel()

    $sourceCopy = $il.DeclareLocal([string[]])
    Emit-IL "LdLoc_S" $sourceLocal.LocalIndex
    Emit-IL "Stloc_S" $sourceCopy.LocalIndex

    $indexLocal = $il.DeclareLocal([int])
    $itemLocal = $il.DeclareLocal([string])
    $itemLocal.SetLocalSymInfo($itemName)

    $il.Emit([System.Reflection.Emit.OpCodes]::Ldc_I4_0)
    Emit-IL "Stloc_S" $indexLocal.LocalIndex
    $il.Emit([System.Reflection.Emit.OpCodes]::Br_S, $label1)

    $il.MarkLabel($label0)
    Emit-IL "LdLoc_S" $sourceCopy.LocalIndex
    Emit-IL "LdLoc_S" $indexLocal.LocalIndex
    $il.Emit([System.Reflection.Emit.OpCodes]::Ldelem_Ref)
    Emit-IL "Stloc_S" $itemLocal.LocalIndex

    # no op
    # ** BODY **
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

Write-ForEach $familyLocal "member"








$il.Emit([System.Reflection.Emit.OpCodes]::Ret)

$typeBuilder.CreateType() | Out-Null

$assemblyBuilder.SetEntryPoint($method, [System.Reflection.Emit.PEFileKinds]::ConsoleApplication);
$assemblyBuilder.Save("BabyShark.exe")

$ildasm = "C:\Program Files (x86)\Microsoft SDKs\Windows\v10.0A\bin\NETFX 4.6.1 Tools\ildasm.exe"

& $ildasm /text /item:Program::Main /source "$basePath\BabyShark.exe"

ilspycmd "$basePath\BabyShark.exe"

# & "$basePath\BabyShark.exe"
