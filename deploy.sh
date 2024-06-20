path="$1"




echo $CREDENTIALS > gcloud-api-key.json
export GOOGLE_APPLICATION_CREDENTIALS=$(pwd)/gcloud-api-key.json
export TF_VAR_function_version=${GITHUB_RUN_NUMBER}_${GITHUB_RUN_ATTEMPT}



if [ $path == "func_1/terraform"]

then
    echo $path
    solutions=(ENG NIG ARG EST)

    echo ${solutions[@]}  

    for i in ${solutions[@]}; do
        echo $i
      
    done

else
  echo $path

fi