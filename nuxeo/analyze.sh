#! /usr/bin/env bash

readonly BASE_BRANCH="base-branch"

print_usage() {
    echo "Usage: ${0}"
    echo ""
    echo "  -b, --branch <branch-name>  Name of the branch to create off the main branch"
    echo "  -c, --cache-enabled         Enable the cache (false by default)"
    echo "  -d, --dbd-enabled           Disable Dataflow Bug Detection analyzer (true by default)"
    echo "  -h, --help                  Print this help message"
}

analyze() {
    local pr_branch
    local cache_enabled="false"
    local dbd_enabled="true"
    for index in $(seq "${#}"); do
        local arg="${!index}"
        case "${arg}" in
            --help|-h)
                print_usage
                exit 0
                ;;
            --branch|-b)
                index="$((index + 1))"
                if [[ "${index}" -gt ${#} ]]; then
                    print_usage
                    exit 0
                fi
                pr_branch="${!index}"
                ;;
            --cache-enabled|-c)
                cache_enabled="true"
                ;;
            --dbd-enabled|-d)
                dbd_enabled="true"
                ;;
        esac
    done


    local current_branch="${BASE_BRANCH}"
    # If a branch name has been passed, create and switch to the branch
    if [[ -n "${pr_branch}" ]]; then
        if git rev-parse --quiet --verify "${pr_branch}" ; then
            git switch "${pr_branch}"
        else
            git switch --create "${pr_branch}"
        fi
        current_branch="${pr_branch}"
    else
        git checkout "${BASE_BRANCH}" --quiet
    fi

    # Create report folders
    local current_date=$(date -u +'%Y-%m-%d-T%H%M%S')
    local reports_folder="/reports/${current_date}"
    mkdir -p "${reports_folder}"
    local using_cache="no-cache"
    if [[ "${cache_enabled}" == "true" ]]; then
        using_cache="with-cache"
    fi
    local analysis_report="${reports_folder}/sq-${using_cache}-${current_branch}.log"
    local performance_report="${reports_folder}/sonar.java.performance.measure-${using_cache}-${current_branch}.json"

    if [[ -z "${pr_branch}" ]]; then
        echo "On the base branch ${BASE_BRANCH}"
        mvn sonar:sonar -B -e \
            -Dsonar.java.jdkHome=JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64 \
            -Dsonar.projectKey=nuxeo \
            -Dsonar.host.url=http://host.docker.internal:9000 \
            -Dsonar.login="${SONARQUBE_TOKEN}" \
            -Dsonar.java.performance.measure=true \
            -Dsonar.java.performance.measure.path="${performance_report}" \
            -Dsonar.branch.name="${current_branch}" \
            -Dsonar.analysisCache.enabled="${cache_enabled}" \
            -Dsonar.internal.analysis.dbd="${dbd_enabled}" > "${analysis_report}"
    else
        echo "Analysing ${current_branch} to merge into base branch ${BASE_BRANCH}"
        mvn sonar:sonar -B -e \
            -Dsonar.java.jdkHome=JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64 \
            -Dsonar.projectKey=nuxeo \
            -Dsonar.host.url=http://host.docker.internal:9000 \
            -Dsonar.login="${SONARQUBE_TOKEN}" \
            -Dsonar.java.performance.measure=true \
            -Dsonar.java.performance.measure.path="${performance_report}" \
            -Dsonar.pullrequest.key="${pr_branch}" \
            -Dsonar.pullrequest.branch="${pr_branch}" \
            -Dsonar.pullrequest.base="${BASE_BRANCH}" \
            -Dsonar.analysisCache.enabled="${cache_enabled}" \
            -Dsonar.internal.analysis.dbd="${dbd_enabled}" > "${analysis_report}"
    fi
}

analyze "${@}"
