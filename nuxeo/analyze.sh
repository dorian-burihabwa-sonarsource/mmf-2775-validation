#! /usr/bin/env bash

readonly base_branch="$(git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@')"


print_usage() {
    echo "Usage: ${0} [--branch <branch-name>]"
    echo ""
    echo "  -b, --branch          Name of the branch to create off the main branch"
    echo "  -c, --cache-enabled   Enable the cache (disabled by default)"
}

analyze() {
    local cache_enabled="false"
    local branch_to_create
    for index in $(seq "${#}"); do
        local arg="${!index}"
        case "${arg}" in
            --branch|-b)
                index="$((index + 1))"
                if [[ "${index}" -gt ${#} ]]; then
                    print_usage
                    exit 0
                fi
                branch_to_create="${!index}"
                ;;
            --cache-enabled|-c)
                cache_enabled="true"
                ;;
        esac
    done

    # Check if the cache needs to be enabled
    cache_enabled=${1}
    if [[ "${cache_enabled}" != "true" && "${cache_enabled}" != "false" ]]; then
        echo "First argument must be true or false to indicate whether to use the cache (received: ${cache_enabled})" >&2
        exit 0
    fi

    # Check if we need to create and move to a new branch
    if [[ "${#}" -eq 2 ]]; then
        branch_to_create="${2}"
        git switch --create "${branch_to_create}"
    fi

    # Create report folders
    local current_date=$(date -u +'%Y-%m-%d-T%H%M%S')
    local reports_folder="/reports/${current_date}"
    mkdir -p "${reports_folder}"
    local current_branch=$(git branch --quiet | grep "\*" | cut -f2 -d" ")
    local using_cache="no-cache"
    if [[ "${cache_enabled}" == "true" ]]; then
        using_cache="with-cache"
    fi
    local analysis_report="${reports_folder}/sq-${using_cache}-${current_branch}.log"
    local performance_report="${reports_folder}/sonar.java.performance.measure-${using_cache}-${current_branch}.json"

    if [[ "${current_branch}" == "${base_branch}" ]]; then
        echo "On the base branch"
        mvn sonar:sonar -B -e \
            -Dsonar.java.jdkHome=JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64 \
            -Dsonar.projectKey=nuxeo \
            -Dsonar.host.url=http://host.docker.internal:9000 \
            -Dsonar.login="${SONARQUBE_TOKEN}" \
            -Dsonar.java.performance.measure=true \
            -Dsonar.java.performance.measure.path="${performance_report}" \
            -Dsonar.branch.name="${current_branch}" \
            -Dsonar.analysisCache.enabled="${cache_enabled}" \
            -Dsonar.internal.analysis.dbd=false > "${analysis_report}"
    else
        echo "Analysing ${current_branch} to merge into base branch ${base_branch}"
        mvn sonar:sonar -B -e \
            -Dsonar.java.jdkHome=JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64 \
            -Dsonar.projectKey=nuxeo \
            -Dsonar.host.url=http://host.docker.internal:9000 \
            -Dsonar.login="${SONARQUBE_TOKEN}" \
            -Dsonar.java.performance.measure=true \
            -Dsonar.java.performance.measure.path="${performance_report}" \
            -Dsonar.pullrequest.key="${current_branch}" \
            -Dsonar.pullrequest.branch="${current_branch}" \
            -Dsonar.pullrequest.base="${base_branch}" \
            -Dsonar.analysisCache.enabled="${cache_enabled}" \
            -Dsonar.internal.analysis.dbd=false > "${analysis_report}"
    fi
}

analyze "${@}"
