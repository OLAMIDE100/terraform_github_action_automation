path="$1"




echo $CREDENTIALS > gcloud-api-key.json
export GOOGLE_APPLICATION_CREDENTIALS=$(pwd)/gcloud-api-key.json
export TF_VAR_function_version=${GITHUB_RUN_NUMBER}_${GITHUB_RUN_ATTEMPT}



if [ $path == "func_1/terraform"]

then
    solutions=(ENG NIG ARG EST)

    echo ${solutions[@]}  
    for i in ${solutions[@]}; do
        echo $i
        export TF_VAR_solution=$i
        echo 'yes' | terraform -chdir=$path init  -backend-config="bucket=nabuminds_terraform-test" -backend-config="prefix=gcp/play-$TF_VAR_solution/state"
        echo 'yes' | terraform -chdir=$path plan
        echo 'yes' | terraform -chdir=$path apply
        rm -rf $path/.terraform
        rm $path/.terraform.lock.hcl
        rm -rf $path/play-$i
    done


else

  echo 'yes' | terraform -chdir=$path init 
  terraform -chdir=$path  plan
  terraform -chdir=$path  apply -auto-approve -input=false 

fi