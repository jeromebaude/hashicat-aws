curl --header "Authorization: Bearer $TOKEN" --header "Content-Type: application/vnd.api+json" --request POST --data @./json_files/apply.json https://app.terraform.io/api/v2/runs
