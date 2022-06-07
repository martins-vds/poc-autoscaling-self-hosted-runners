AKS_ADMIN_GROUP_NAMES="Vinima - AKS Admins"
adGroupNames=$(echo $AKS_ADMIN_GROUP_NAMES | tr "," "\n")
adGroupIds=()

for groupName in "${adGroupNames[@]}"; do
    objectId=$(az ad group list --filter "displayName eq '$groupName'" --query "[].{id:id}" -o tsv --only-show-errors)
    adGroupIds+=("$objectId")
done

adGroupIdsJson=$(jq -n --arg inarr "${adGroupIds}" '$inarr | split("\n")' --compact-output)
echo "adminGroupObjectIDs=$adGroupIdsJson"