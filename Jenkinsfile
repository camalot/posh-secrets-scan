#!groovy
import com.bit13.jenkins.*


node ("powershell") {
	def ProjectName = "posh-secrets-scan"
	def slack_notify_channel = null

	def SONARQUBE_INSTANCE = "bit13"


	properties ([
		buildDiscarder(logRotator(numToKeepStr: '25', artifactNumToKeepStr: '25')),
		disableConcurrentBuilds()
	])


	def MAJOR_VERSION = 1
	def MINOR_VERSION = 0

	env.PROJECT_MAJOR_VERSION = MAJOR_VERSION
	env.PROJECT_MINOR_VERSION = MINOR_VERSION

	env.CI_BUILD_VERSION = Branch.getSemanticVersion(this)
	env.CI_DOCKER_ORGANIZATION = Accounts.GIT_ORGANIZATION
	env.CI_PROJECT_NAME = ProjectName
	currentBuild.result = "SUCCESS"
	def errorMessage = null

	if(env.BRANCH_NAME ==~ /master$/) {
			return
	}

	wrap([$class: 'TimestamperBuildWrapper']) {
		wrap([$class: 'AnsiColorBuildWrapper', colorMapName: 'xterm']) {
			Notify.slack(this, "STARTED", null, slack_notify_channel)
			try {
				stage ("install" ) {
					deleteDir()
					Branch.checkout(this, env.CI_PROJECT_NAME)
					Pipeline.install(this)
				}
				stage ("build") {
					Powershell.run(sender: this, xxx: "Get-ChildItems -Path ${WORKSPACE}")
					Powershell.run(sender: this, yyy: "${WORKSPACE}/.deploy/build.ps1")
				}
				stage ("test") {
					Powershell.run(sender: this, yyy: "${WORKSPACE}/.deploy/test.ps1")
				}
				stage ("deploy") {
					Powershell.run(sender: this, yyy: "${WORKSPACE}/.deploy/deploy.ps1")
				}
				stage ('publish') {
					// this only will publish if the incominh branch IS develop
					Branch.publish_to_master(this)
					Pipeline.publish_buildInfo(this)
				}
			} catch(err) {
				currentBuild.result = "FAILURE"
				errorMessage = err.message
				throw err
			}
			finally {
				Pipeline.finish(this, currentBuild.result, errorMessage)
			}
		}
	}
}
