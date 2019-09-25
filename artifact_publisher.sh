#!/bin/bash

GROUP_ID="<Group ID to be taken as input>"
ARTIFACT_ID="<Artifact Id to be taken as input>"
GITHUB_OWNER="<Github username to be taken as input>"
GITHUB_REPO="<Github Repo name to be taken as input>"
VERSION="<Artifact version to be taken as input>"
FILE="<Local Path to the jar file>"
PACKAGING=jar

TEMP_REPO="$HOME/.git2m2/$GITHUB_OWNER/$GITHUB_REPO"
REPOSITORY="https://github.com/$GITHUB_OWNER/$GITHUB_REPO"

#Function to take user inputs
takeUserInput(){
    read -p 'Group Id: ' GROUP_ID
    read -p 'Artifact Id: ' ARTIFACT_ID
    read -p 'Github username: ' GITHUB_OWNER
    read -p 'Github REPOSITORY name for deploying artifact: ' GITHUB_REPO
    read -p 'Artifact Version: ' VERSION
    read -p 'File Path to the jar file: ' FILE
}

#Function to create a local repo of the remote repo
createLocalRepo()
{
    rm -rf "$TEMP_REPO"
    if [ -d "$TEMP_REPO" ]; then
        echo "Deleting the existing directory"
        rm -rf "$TEMP_REPO"
    fi
    
    echo "Cloning from $REPOSITORY into $TEMP_REPO"
    git clone "$REPOSITORY" "$TEMP_REPO"
}

#Function to execute maven commands for creation the artifact
generateMavenArtifact()
{
    echo "Generating artifacts for $GROUP_ID/$ARTIFACT_ID/$VERSION from $FILE into $REPOSITORY"

    mvn deploy:deploy-file -DgroupId="$GROUP_ID" -DartifactId="$ARTIFACT_ID" \
        -Dversion="$VERSION" -Dfile="$FILE" -Dpackaging="$PACKAGING" -DgeneratePom=true -DcreateChecksum=true \
        -Durl="file:///$TEMP_REPO/.m2" -e

    echo "Maven artifact successfully generated"
}

#Publish the created artifact to github
commitAndPushChanges()
{
    pushd "$TEMP_REPO"

    echo "Adding all changes to git"
    git add -A 
    git commit -m "Release $GROUP_ID/$ARTIFACT_ID version $VERSION"

    echo "Pushing to $REPOSITORY"
    git push

    popd
}

#Fucntion to print the repo path which must be included in all your maven projects
printRepoPath()
{
    echo "============================"
    echo "Your Maven URL is https://raw.githubusercontent.com/$GITHUB_OWNER/$GITHUB_REPO/tree/master/.m2"
    echo "============================"
}

set -e
takeUserInput
createLocalRepo
generateMavenArtifact
commitAndPushChanges
printRepoPath
set +e