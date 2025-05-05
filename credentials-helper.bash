#!/usr/bin/env bash
# CK8S_DEVBOX_MAJOR_VERSION=10

# Gets personal credentials for various cloud providers.
# Requires the user to add how they want the credentials to be retrieved,
# e.g. via a password manager like pass or by sourcing an encrypted file.
# Outputs the credentials as a json object.

set -e

usage() {
    echo "Usage:" 1>&2
    echo " $(basename "${0}") <safespring|elastx|aws|elastisys>" 1>&2
    echo " $(basename "${0}") citycloud region" 1>&2
    echo " $(basename "${0}") upcloud main-account-name" 1>&2
    echo " $(basename "${0}") exoscale project-name" 1>&2
    exit 1
}

if [[ $# -lt 1 ]]; then
    usage
fi

cloud_provider="${1}"

if [[ $# != 2 && ("${cloud_provider}" == "citycloud" || "${cloud_provider}" == "upcloud" || "${cloud_provider}" == "exoscale") ]]; then
    usage
fi

if [[ $# -gt 1 ]]; then
    case "${cloud_provider}" in
        citycloud)
            region="${2}"
            ;;
        upcloud)
            # shellcheck disable=SC2034
            main_account_name="${2}"
            ;;
        exoscale)
            # shellcheck disable=SC2034
            project_name="${2}"
            ;;
    esac
fi

# Change "change-me-function" for your preferred method of getting credentials
# The json format echoed at the end of every case must not be modified

case "${cloud_provider}" in
    citycloud)
        case "${region}" in
            kna1)
                # Get credentials for citycloud kna1
                OS_USERNAME="$(pass citycloud/kna1/username)"
                OS_PASSWORD="$(pass citycloud/kna1/password)"
                echo "{\"id\": \"${OS_USERNAME}\", \"secret\": \"${OS_PASSWORD}\"}"
                ;;
            fra1)
                # Get credentials for citycloud fra1
                OS_USERNAME="$(pass citycloud/fra1/username)"
                OS_PASSWORD="$(pass citycloud/fra1/password)"
                echo "{\"id\": \"${OS_USERNAME}\", \"secret\": \"${OS_PASSWORD}\"}"
                ;;
            compliantcloud)
                # Get credentials for citycloud compliantcloud
                OS_USERNAME="$(pass citycloud/compliantcloud/username)"
                OS_PASSWORD="$(pass citycloud/compliantcloud/password)"
                echo "{\"id\": \"${OS_USERNAME}\", \"secret\": \"${OS_PASSWORD}\"}"
                ;;
            *)
                echo "ERROR: Unsupported citycloud region" >&2
                echo "Supported citycloud regions: kna1 fra1 compliantcloud" >&2
                exit 1
                ;;
        esac
        ;;
    elastisys)
        # Get credentials for elastisys
        OS_APPLICATION_CREDENTIAL_ID="$(rbw get coffee-brewer --field=username)"
        OS_APPLICATION_CREDENTIAL_SECRET="$(rbw get coffee-brewer --field=password)"
        echo "{\"id\": \"${OS_APPLICATION_CREDENTIAL_ID}\", \"secret\": \"${OS_APPLICATION_CREDENTIAL_SECRET}\"}"
        ;;
    safespring)
        # Get credentials for safespring
        OS_USERNAME="$(rbw get safespring --field=username)"
        OS_PASSWORD="$(rbw get safespring --field=password)"
        echo "{\"id\": \"${OS_USERNAME}\", \"secret\": \"${OS_PASSWORD}\"}"
        ;;
    upcloud)
        # Get credentials for upcloud
        # Make sure that your function gets the correct sub-account credentials based on ${main_account_name}
        UPCLOUD_SUBACCOUNT_USERNAME="$(rbw get "${main_account_name}" --field=username )"
        UPCLOUD_SUBACCOUNT_PASSWORD="$(rbw get "${main_account_name}" --field=password)"
        echo "{\"id\": \"${UPCLOUD_SUBACCOUNT_USERNAME}\", \"secret\": \"${UPCLOUD_SUBACCOUNT_PASSWORD}\"}"
        ;;
    elastx)
        # Get credentials for elastx
        OS_USERNAME="$(rbw get elastx --field=username)"
        OS_PASSWORD="$(rbw get elastx --field=password)"
        echo "{\"id\": \"${OS_USERNAME}\", \"secret\": \"${OS_PASSWORD}\"}"
        ;;
    aws)
        # Get credentials for AWS
        # Needed for DNS setup
        AWS_ACCESS_KEY_ID="$(rbw get aws-devbox --field=username)"
        AWS_SECRET_ACCESS_KEY="$(rbw get aws-devbox --field=password)"
        echo "{\"id\": \"${AWS_ACCESS_KEY_ID}\", \"secret\": \"${AWS_SECRET_ACCESS_KEY}\"}"
        ;;
    exoscale)
        # Get credentials for exoscale
        # Make sure that your function gets the correct project credentials based on ${project_name}
        EXOSCALE_KEY="$(pass exoscale/"${project_name}"/key)"
        EXOSCALE_SECRET="$(pass exoscale/"${project_name}"/secret)"
        echo "{\"id\": \"${EXOSCALE_KEY}\", \"secret\": \"${EXOSCALE_SECRET}\"}"
        ;;
    *)
        usage
        ;;
esac
