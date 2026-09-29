@Library('iaslab-pipeline-library@v1.0') _

standardPipeline(
    serviceName: 'microservicio-backend',
    buildType: 'maven',
    jdkVersion: '17',
    publishJar: true,
    publishDocker: true,
    nexusHost: '3.19.56.45',    // <--- Coloca aquí la IP pública de tu ec2-nexus
    dockerPort: '9080',
    deployTarget: '3.148.105.234', // <--- Coloca aquí la IP pública de tu ec2-deploy
    healthEndpoint: '/api/products' // Endpoint que responde 200 OK
)
