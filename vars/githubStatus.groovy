// vars/githubStatus.groovy 
import groovy.json.JsonOutput

def call(Map config) {
    // Default values
    def status = config.status ?: 'PENDING'
    def context = config.context ?: 'Jenkins Build'
    def message = config.message ?: 'Jenkins build status'
    def targetUrl = config.targetUrl ?: env.BUILD_URL
    def commit = config.commit ?: env.GIT_COMMIT
    def credentialsId = config.credentialsId ?: 'github-api'
    def githubOrg = config.githubOrganization ?: env.GITHUB_ORGANIZATION
    def githubRepo = config.githubRepository ?: env.GITHUB_REPO

    if (!githubOrg || !githubRepo || !commit) {
        error "Missing required parameters for GitHub status update. githubOrganization, githubRepository, and commit are needed."
    }

    // Build the JSON payload
    def payload = [
        state      : status.toLowerCase(),
        target_url : targetUrl,
        description: message,
        context    : context
    ]
    def jsonPayload = JsonOutput.toJson(payload)

    withCredentials([string(credentialsId: credentialsId, variable: 'GITHUB_TOKEN')]) {
        sh """
            curl -X POST -H "Authorization: token $GITHUB_TOKEN" \\
            -H "Accept: application/vnd.github.v3+json" \\
            "https://api.github.com/repos/${githubOrg}/${githubRepo}/statuses/${commit}" \\
            -d '${jsonPayload}'
        """
    }
}