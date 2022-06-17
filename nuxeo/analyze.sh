#! /usr/bin/env bash

readonly base_branch="$(git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@')"

analyze() {
    local current_date=$(date -u +'%Y-%m-%d-T%H%M%S')
    local reports_folder="/reports/${current-date}/"
    local current_branch=$(git branch --quiet | grep "\*" | cut -f2 -d" ")
    echo "${current_branch}"
    local analysis_report="${reports_folder}/sq-${current_date}-nocache-${current_branch}.log"
    local performance_report="${reports_folder}/sonar.java.performance.measure-${current_date}-nocache-${current_branch}.json"
    if [[ "${current_branch}" == "${base_branch}" ]]; then
        echo "On the base branch"
        mvn sonar:sonar -B -e \
            -Dsonar.java.jdkHome=JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64 \
            -Dsonar.projectKey=nuxeo \
            -Dsonar.host.url=http://host.docker.internal:9000 \
            -Dsonar.login="${SONARQUBE_TOKEN}" \
            -Dsonar.java.performance.measure=true \
            -Dsonar.java.performance.measure.path="${performance_report}" \
            -Dsonar.analysisCache.enabled=true \
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
            -Dsonar.analysisCache.enabled=false \
            -Dsonar.internal.analysis.dbd=false > "${analysis_report}"
    fi
}

analyze
