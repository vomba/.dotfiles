#!/usr/bin/env bash
#
# Credential Helper Script
# ========================
# This script retrieves cloud provider credentials from password managers.
#
# SECURITY NOTES:
# - Credentials are NEVER stored in this script or any config files
# - Uses 'pass' (https://www.passwordstore.org/) or 'rbw' (https://git.zx2c4.com/rbw)
# - All credential entries must be pre-configured in your password manager
# - Script outputs JSON with 'id' and 'secret' fields only
#
# PASSWORD MANAGER SETUP:
# For pass: Initialize with 'pass init your-gpg-key-id'
# For rbw:  Configure with 'rbw config' after installing rbw
#
# DANGER ZONE - NEVER DO:
# - Commit credentials to git
# - Hardcode credentials in any file
# - Share credential entries or passwords
# - Use password managers without master password protection
#
# USAGE:
#   ./credentials-helper.bash <provider> [args]
#
# PROVIDERS:
#   safespring              - Get safespring credentials
#   elastx                  - Get elastx credentials
#   aws                     - Get AWS credentials
#   elastisys               - Get elastisys credentials
#   citycloud <region>      - Get citycloud credentials (regions: kna1, fra1, compliantcloud)
#   upcloud <account-name>  - Get upcloud credentials for specific account
#   exoscale <project-name>  - Get exoscale credentials for specific project
#
# OUTPUT FORMAT (JSON):
#   {"id": "username", "secret": "password"}
#

set -e

# Verify password managers are available
check_password_manager() {
	if ! command -v pass &>/dev/null && ! command -v rbw &>/dev/null; then
		echo "ERROR: Neither 'pass' nor 'rbw' password manager is installed" >&2
		echo "Install one of them to use this credential helper" >&2
		exit 1
	fi
}

check_password_manager

usage() {
	echo "Usage:" 1>&2
	echo " $(basename "${0}") <safespring|elastx|aws|elastisys>" 1>&2
	echo " $(basename "${0}") citycloud <region>" 1>&2
	echo " $(basename "${0}") upcloud <main-account-name>" 1>&2
	echo " $(basename "${0}") exoscale <project-name>" 1>&2
	echo "" 1>&2
	echo "Regions for citycloud: kna1 fra1 compliantcloud" 1>&2
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

# The JSON format echoed at the end of every case must not be modified
# This ensures compatibility with any tools consuming this output

case "${cloud_provider}" in
citycloud)
	case "${region}" in
	kna1)
		# Retrieve from pass password manager
		OS_USERNAME="$(pass citycloud/kna1/username)"
		OS_PASSWORD="$(pass citycloud/kna1/password)"
		echo "{\"id\": \"${OS_USERNAME}\", \"secret\": \"${OS_PASSWORD}\"}"
		;;
	fra1)
		OS_USERNAME="$(pass citycloud/fra1/username)"
		OS_PASSWORD="$(pass citycloud/fra1/password)"
		echo "{\"id\": \"${OS_USERNAME}\", \"secret\": \"${OS_PASSWORD}\"}"
		;;
	compliantcloud)
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
	# Retrieve from rbw password manager
	OS_APPLICATION_CREDENTIAL_ID="$(rbw get coffee-brewer --field=username)"
	OS_APPLICATION_CREDENTIAL_SECRET="$(rbw get coffee-brewer --field=password)"
	echo "{\"id\": \"${OS_APPLICATION_CREDENTIAL_ID}\", \"secret\": \"${OS_APPLICATION_CREDENTIAL_SECRET}\"}"
	;;
safespring)
	OS_USERNAME="$(rbw get safespring --field=username)"
	OS_PASSWORD="$(rbw get safespring --field=password)"
	echo "{\"id\": \"${OS_USERNAME}\", \"secret\": \"${OS_PASSWORD}\"}"
	;;
upcloud)
	# Ensure correct sub-account credentials based on ${main_account_name}
	UPCLOUD_SUBACCOUNT_USERNAME="$(rbw get "${main_account_name}" --field=username)"
	UPCLOUD_SUBACCOUNT_PASSWORD="$(rbw get "${main_account_name}" --field=password)"
	echo "{\"id\": \"${UPCLOUD_SUBACCOUNT_USERNAME}\", \"secret\": \"${UPCLOUD_SUBACCOUNT_PASSWORD}\"}"
	;;
elastx)
	OS_USERNAME="$(rbw get ops.elastx.cloud --field=username)"
	OS_PASSWORD="$(rbw get ops.elastx.cloud --field=password)"
	echo "{\"id\": \"${OS_USERNAME}\", \"secret\": \"${OS_PASSWORD}\"}"
	;;
aws)
	# Retrieve AWS credentials for DNS setup
	AWS_ACCESS_KEY_ID="$(rbw get aws-devbox --field=username)"
	AWS_SECRET_ACCESS_KEY="$(rbw get aws-devbox --field=password)"
	echo "{\"id\": \"${AWS_ACCESS_KEY_ID}\", \"secret\": \"${AWS_SECRET_ACCESS_KEY}\"}"
	;;
exoscale)
	# Retrieve exoscale credentials for specific project
	EXOSCALE_KEY="$(rbw get exso --field=username)"
	EXOSCALE_SECRET="$(rbw get exso --field=password)"
	echo "{\"id\": \"${EXOSCALE_KEY}\", \"secret\": \"${EXOSCALE_SECRET}\"}"
	;;
*)
	usage
	;;
esac
