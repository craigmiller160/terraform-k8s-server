
# $1 = env
function get_env {
  case $1 in
    "dev") source ./scripts/dev.env ;;
    "prod") source ./scripts/prod.env ;;
    *)
      echo "Invalid environment: $1"
      exit 1
    ;;
  esac
}

# $1 = Directory
function validate_phase {
  case $1 in
    "phase1"|"phase2"|"phase3")
      echo "Infrastructure phase: $1"
    ;;
    *)
      echo "Invalid infrastructure phase: $1"
      exit 1
    ;;
  esac
}

# $1 = Command
function get_backend_context {
  if [ $1 == "init" ]; then
    echo "-backend-config=config_context=$k8s_context"
  else
    echo ""
  fi
}

# $1 = Directory, $2 Command
function get_secrets_file {
  if [ $2 == "fmt" ]; then
    echo ""
  elif [ -f "$1/secrets.tfvars" ]; then
    echo "-var-file=secrets.tfvars"
  else
    echo ""
  fi
}

# $1 = Directory, $2 Command
function get_nexus_image_var {
  if [ $2 == "fmt" ]; then
    echo ""
  elif [ $1 == "phase2" ]; then
    echo "-var=nexus_image=$nexus_image"
  else
    echo ""
  fi
}

# $1 = Directory, $2 = Command
function get_k8s_context_var {
  if [ $2 == "fmt" ]; then
    echo ""
  else
    case $1 in
      "phase1"|"phase2")
        echo "-var=k8s_context=$k8s_context"
      ;;
      *)
        echo ""
      ;;
    esac
  fi
}

# $1 = env, $2 = Directory, #3 = Command
function run {
  get_env $1
  validate_phase $2

  backend_arg=$(get_backend_context $3)
  secrets_file=$(get_secrets_file $2 $3)
  nexus_image_var=$(get_nexus_image_var $2 $3)
  k8s_context_var=$(get_k8s_context_var $2 $3)

  (
    cd "$2" &&
    terraform ${@:3} \
      $k8s_context_var \
      $backend_arg \
      $secrets_file \
      $nexus_image_var
  )
}