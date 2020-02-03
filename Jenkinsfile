pipeline {
    environment {
      def version = "${env.BUILD_NUMBER}"
      def filename = "app-${env.BUILD_NUMBER}.jar"

    }
    agent any
    stages {
      stage ('Build '){

      steps {

           withAWS(credentials: 'aws-credentials', region: 'eu-central-1') {
              sh "chmod +x gradlew"
              sh "./gradlew -Pversion=test build"
              s3Upload acl: 'Private', bucket: 'neo-airlines-artifact', file: 'build/libs/app-0.0.1-SNAPSHOT.jar', path: 'app.jar'
          }
      }

      }
      stage ('Docker publish'){
          agent {
          kubernetes {
          //cloud 'kubernetes'
          defaultContainer 'kaniko'
          yaml """
          kind: Pod
          spec:
            containers:
              - name: kaniko
                image: gcr.io/kaniko-project/executor:debug
                imagePullPolicy: Always
                command:
                - /busybox/cat
                tty: true
                volumeMounts:
                  - name: kaniko-secret
                    mountPath: /secret
                  - name: aws-secret
                    mountPath: /kaniko/.aws/

            volumes:
              - name: kaniko-secret
                secret:
                  secretName: kaniko-secret
              - name: aws-secret
                secret:
                  secretName: aws-secret
       """
       }
          }


          steps {withAWS(credentials: 'aws-credentials', region: 'eu-central-1'){
          s3Download bucket: 'neo-airlines-artifact', file: 'app.jar', path: 'app.jar'
          sh '/kaniko/executor -f `pwd`/Dockerfile -c `pwd` --build-arg BUILD_PROFILE="Build_Number ${version}" --cache=true --destination=632894146407.dkr.ecr.eu-central-1.amazonaws.com/neo-demo:latest --destination=632894146407.dkr.ecr.eu-central-1.amazonaws.com/neo-demo:"${version}" '


          }
          }
      }
      stage('Build in Dev') {
          steps {
            sh("helm init --client-only --skip-refresh")
            sh("helm upgrade --install --namespace dev neo-app --set buildName='Build Number ${env.BUILD_NUMBER}' neo-demo-app")
          }
      }

    }

}
