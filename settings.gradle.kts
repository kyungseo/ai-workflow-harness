rootProject.name = "base-msa-template"

dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories {
        mavenCentral()
    }
}

include("common:common-core")
include("gateway:api-gateway")
include("services:auth-service")
include("services:user-service")
include("services:todo-service")
