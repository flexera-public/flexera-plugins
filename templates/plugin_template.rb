# <filename>
#==============================================================================================
# Copyright <YEAR> <COPYRIGHT HOLDER>
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy of this
# software and associated documentation files (the "Software"), to deal in the Software
# without restriction, including without limitation the rights to use, copy, modify, merge,
# publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons
# to whom the Software is furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all copies or
# substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING
# BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
# DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#
#==============================================================================================
# DESCRIPTION: <plugin description>
# AUTHOR: <author email>
#
#==============================================================================================
# HISTORY
#   yyyy/mm/dd : <user> : <what changed>
#==============================================================================================

# INSERT PLUGIN NAME
name ""
rs_ca_ver 20161221
#INSERT PLUGIN DESCRIPTIONS
short_description ""
long_description ""

type 'plugin'

# INSERT PLUGIN PACKAGE NAME
package "" 

# Plugin API Documentation: <INSERT LINK HERE>
# INSERT PLUGIN NAME (ONLY REFERENCED FROM THIS FILE)
plugin "" do

  endpoint do
    default_scheme "" #(http|https)
    default_host "" #Host of the API endpoint
    path "/" # Base path
  end

  # Name: <Resource Name>
  # Description: <Resource Description> 
  # Usage:
  # <CAT/RCL Example of how to use this resource>
  # Notes:
  # <Special Notes>
  type "" do
    href_templates "/job/{{jobID}}/status"
    
    field "authentication_token" do
      type "string"
      location "header"
      alias_for "Authentication-Token"
    end
    
    action "create" do
      verb "POST"
      path "/process/$process_name/execute"
    end

    action "update" do
      path "$href"
    end

    action "list" do
      path ""
    end
    
    action "get" do
      path "$href"
    end

    provision "provision_resource"
    delete "delete_resource" 
  end
end

define provision_resource(@raw) return @resource do
end

define delete_resource(@raw) do
end

# INSERT RESOURCE POOL NAME (This is what you reference in the CAT)
resource_pool "" do
  plugin $<plugin_name> # INSERT PLUGIN NAME FROM plugin "" line
  
  # See docs for auth details
  # http://docs.rightscale.com/ss/reference/cat/v20161221/ss_plugins.html#resource-pools-authentication
  auth "my_basic_auth", type: "basic" do
    # Basic auth username
    # Uses standard CAT field syntax
    username "user"
    # Basic auth password
    # Uses standard CAT field syntax
    password cred("PASSWORD")
  end
end
