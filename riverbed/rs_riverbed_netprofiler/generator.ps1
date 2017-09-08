$api = curl https://support.riverbed.com/apis/profiler/1.7/service.json | convertfrom-json
$resources = @($api.resources)
$resource_names = ($resources | gm -MemberType NoteProperty).name

$pluginName = "Netprofiler"
$pluginNamespace = "netprofiler"
$pluginResourcePool = "netprofiler"
$pluginVer = "20161221"
$pluginShortDesc = "Netprofiler Plugin"
$pluginLongDesc = "Version: 1.0"
$pluginImports = ["sys_log"]
$pluginDefaultScheme = "https"
$pluginDefaultHost = ""
$pluginPath = ""

$types = @()
foreach ($name in $resource_names) {
  $type = $null
  $type = "type `"$($name.ToLower())`" do`n"
  $type = $type + "  href_templates `"`"`n  provision `"provision_resource`"`n  delete `"delete_resource`"`n`n"

  $method_names = ($resources.$name.methods | Get-Member -MemberType NoteProperty -ErrorAction SilentlyContinue).Name
  $parameter_names = @()
  $field_names = @()
  foreach ($method in $method_names) { 
    $action_fields = $null
    $action_fields = ($resources.$name.methods.$method.request.properties | Get-Member -MemberType NoteProperty -ErrorAction SilentlyContinue).Name
    $action_params = ($resources.$name.methods.$method.parameters | Get-Member -MemberType NoteProperty -ErrorAction SilentlyContinue).Name
    $parameter_names += $action_params 
    $field_names += $action_fields 
  }
  $parameter_names = $parameter_names | Select-Object -Unique
  $field_names = $field_names | Select-Object -Unique
  $fields = @()
  foreach ($field in $field_names) {
    $field_type = $null
    $required = $null
    foreach ($method in $method_names) {
      $field_type = $resources.$name.methods.$method.request.properties.$field.type
      $required = $resources.$name.methods.$method.request.properties.$field.required
      if ($field_type) { break }
    }
    if ($required -eq "True") {
      $field = "  field `"$field`" do`n    type `"$field_type`"`n    location `"body`"`n    required true`n  end`n"
    } else {
      $field = "  field `"$field`" do`n    type `"$field_type`"`n    location `"body`"`n  end`n"
    }
    $fields += $field
  }
  foreach ($field in $parameter_names) {
    $field_type = $null
    $required = $null
    foreach ($method in $method_names) {
      $field_type = $resources.$name.methods.$method.parameters.$field.type
      $required = $resources.$name.methods.$method.parameters.$field.required
      if ($field_type) { break }
    }
    if ($required -eq "True") {
      $field = "  field `"$field`" do`n    type `"$field_type`"`n    location `"query`"`n    required true`n  end`n"
    } else {
      $field = "  field `"$field`" do`n    type `"$field_type`"`n    location `"query`"`n  end`n"
    }
    $fields += $field
  }
  $type = $type + $fields
  $types = $types + $type
}


