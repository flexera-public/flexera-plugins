- pre-req
  - ENABLE GOOGLE CLOUD SQL API if not already enabled -- https://cloud.google.com/sql/docs/mysql/admin-api/#activating_the_api

- Instances
  - OUTPUTS FIX >> nested outputs, etc

- Users
  - Can't construct a unique URI to GET a User resource.  `/users/<username>`, `/users?name=<username>`, etc. are no bueno.
  - Document that this will be a "limited" resource type