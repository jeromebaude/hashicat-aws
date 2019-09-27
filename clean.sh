#!/bin/bash

rm -f remote_backend.tf
cp ./ORG/deploy_app.sh ./files/deploy_app.sh
cp ./ORG/main.tf ./
cp ./ORG/outputs.tf ./
cp ./ORG/terraform.tfvars terraform.tfvars.example

git add remote_backend.tf ./files/deploy_app.sh main.tf outputs.tf terraform.tfvars.example clean.sh
git commit -m "initial restore"
git push origin master

