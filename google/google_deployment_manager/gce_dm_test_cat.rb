name "Google Cloud Deployment Manager - Test CAT"
rs_ca_ver 20161221
short_description "Google Cloud Deployment Manager - Test CAT"
import "plugins/gce_dm"

parameter "gce_project" do
  like $gce_dm.gce_project
  default "rightscale.com:services1"
end

operation "launch" do
  definition "gen_launch"
end

resource "gce_dm_deployment", type: "gce_dm.deployment" do
  name join(["beyondtrust-",last(split(@@deployment.href, "/"))])
  target do {
    "config" => {
      "content" => '{
        "imports": [
          {
            "path": "beyondtrust.jinja"
          }
        ],
        "resources": [
          {
            "name": "beyondtrust",
            "type": "beyondtrust.jinja",
            "properties": {
              "zone": "us-central1-a",
              "machineType": "n1-standard-8",
              "bootDiskType": "pd-standard",
              "bootDiskSizeGb": 100,
              "network": "default",
              "subnetwork": "default",
              "externalIP": "Ephemeral",
              "tcp443SourceRanges": "",
              "enableTcp443": true,
              "ipForward": "On"
            }
          }
        ]
      }'
    },
    "imports" =>  [
    ]
  } end
end

define gen_launch(@gce_dm_deployment,$gce_project) return @gce_dm_deployment, @bt_deployment do
  $imports = []
  $additional_imports = [
    { "name" => "beyondtrust.jinja.schema", "url" => "https://s3.amazonaws.com/gce-dm-templates/beyondtrust.jinja.schema"},
    { "name" => "beyondtrust.jinja.display", "url" => "https://s3.amazonaws.com/gce-dm-templates/beyondtrust.jinja.display"},
    { "name" => "resources/en-us/beyondtrust_small.png", "url" => "https://s3.amazonaws.com/gce-dm-templates/beyondtrust_small.png"},
    { "name" => "resources/en-us/beyondtrust_store.png", "url" => "https://s3.amazonaws.com/gce-dm-templates/beyondtrust_store.png"},
    { "name" => "beyondtrust.jinja", "url" => "https://s3.amazonaws.com/gce-dm-templates/beyondtrust.jinja" },
    { "name" => "c2d_deployment_configuration.json", "url" => "https://s3.amazonaws.com/gce-dm-templates/c2d_deployment_configuration.json"},
    { "name" => "password.py", "url" => "https://s3.amazonaws.com/gce-dm-templates/password.py"},
    { "name" => "path_utils.jinja", "url" => "https://s3.amazonaws.com/gce-dm-templates/path_utils.jinja"},
    { "name" => "test_config.yaml", "url" => "https://s3.amazonaws.com/gce-dm-templates/test_config.yaml"}
  ]
  
  foreach $import in $additional_imports do
    call gce_dm.get_additional_import($import) retrieve $data
    $imports << $data
  end

  $google_imports = [ 
    { "name" => "common.py"},
    { "name" => "default.py"},
    { "name" => "software_status.py"},
    { "name" => "software_status.py.schema"},
    { "name" => "software_status.sh.tmpl"},
    { "name" => "software_status_script.py"},
    { "name" => "software_status_script.py.schema"},
    { "name" => "vm_instance.py"} ]
  foreach $import in $google_imports do
    call gce_dm.get_google_import($import["name"]) retrieve $data
    $imports << $data
  end
  $dm = to_object(@gce_dm_deployment)
  $dm["fields"]["target"]["imports"] = $imports
  @gce_dm_deployment = $dm
  provision(@gce_dm_deployment)
  call gce_dm.start_debugging()
  @bt_deployment = gce_dm.deployment.show(operation_href: join(["/deploymentmanager/v2/projects/",$gce_project,"/global/deployments/beyondtrust-1"]))
  call gce_dm.stop_debugging()
end

