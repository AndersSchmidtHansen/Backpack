alias reloadVagrant='cd $(dirname $(find / -name Homestead.yaml  2>/dev/null | head -n 1)); vagrant reload --provision;'
newSidequestProject(){

  PROJECT_NAME=$1;
  val=$(echo $PROJECT_NAME | tr '[:upper:]' '[:lower:]');
  PROJECT_NAME="$val";

  # Add the project to hosts file
  sudo bash -c "echo '127.0.0.1 $PROJECT_NAME.app' >> /etc/hosts";

  # Add the project to the Homestead.yaml
  find . -name 'Homestead.yaml' -exec sh -c "echo '\n    - map: $PROJECT_NAME.app\n      to: /home/vagrant/Homestead/$1/public' >> {}" \;

  git clone git@github.com:AndersSchmidtHansen/sidequest.git $1;
  cd $1;
  PROJECT_FOLDER=$(pwd);

  # Replace default project name with the one defined by
  # the user.
  sed -i "s/sidequest.app/$PROJECT_NAME.app/g" gulpfile.coffee;
  sed -i "s/sidequest.app/$PROJECT_NAME.app/g" .env.local.php;
  sed -i "s/Sidequest/$1/g" .env.local.php;

  sudo npm install;
  php artisan key:generate;

  # Jump over and reload Vagrant
  reloadVagrant

  # When done, go back to the project folder
  cd $PROJECT_FOLDER;

  gulp;
}
alias sidequest=newSidequestProject;

initializeSidequest() {
  find . -name 'Homestead.yaml' -exec sh -c "echo '\n sites:' >> {}" \;
}

alias sidequest:init=initializeSidequest;