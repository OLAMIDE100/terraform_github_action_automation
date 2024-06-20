export GOOGLE_APPLICATION_CREDENTIALS=/Users/adebimpe/Desktop/Irrational_Capital_Phase_Two/test.json
export TF_VAR_gcp_project_name=nabuminds-test


solutions=(ENG NIG ARG EST)

echo ${solutions[@]}

for i in ${solutions[@]}; do
    echo $i
    export TF_VAR_solution=$i
    echo 'yes' | terraform -chdir=terraform init  -backend-config="bucket=nabuminds_terraform-test" -backend-config="prefix=gcp/$TF_VAR_solution/state"
    echo 'yes' | terraform -chdir=terraform plan
    echo 'yes' | terraform -chdir=terraform apply
    rm -rf terraform/.terraform
    rm terraform/.terraform.lock.hcl
    rm -rf terraform/play-$i
done