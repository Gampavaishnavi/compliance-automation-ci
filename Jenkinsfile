pipeline {
    agent any

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Run InSpec Compliance Scan') {
            steps {
                sh '''
                mkdir -p inspec_results
                docker run --rm \
                  -e CHEF_LICENSE=accept \
                  -v $(pwd):/work \
                  chef/inspec:latest \
                  exec /work/inspec_profiles/aws_compliance \
                  -t local:// \
                  --reporter json:/work/inspec_results/result.json
                '''
            }
        }

        stage('OPA Policy Evaluation') {
            steps {
                sh '''
                opa eval \
                  --input inspec_results/result.json \
                  --data policies/sample.rego \
                  "data.compliance.allow" > opa_result.json
                '''
            }
        }

        stage('Compliance Gate') {
            steps {
                sh '''
                if grep -q '"value": true' opa_result.json; then
                    echo "COMPLIANCE PASSED – Proceeding"
                else
                    echo "COMPLIANCE FAILED – Blocking Pipeline"
                    exit 1
                fi
                '''
            }
        }
    }

    post {
        always {
            archiveArtifacts artifacts: 'inspec_results/*.json, opa_result.json'
        }
        failure {
            echo 'Pipeline blocked due to compliance violations'
        }
        success {
            echo 'Pipeline passed compliance checks'
        }
    }
}

