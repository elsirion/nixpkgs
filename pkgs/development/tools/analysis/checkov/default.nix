{ lib
, fetchFromGitHub
, python3
}:

let
  py = python3.override {
    packageOverrides = self: super: {
      cyclonedx-python-lib = super.cyclonedx-python-lib.overridePythonAttrs (oldAttrs: rec {
        version = "2.7.1";
        src = fetchFromGitHub {
          owner = "CycloneDX";
          repo = "cyclonedx-python-lib";
          rev = "v${version}";
          hash = "sha256-c/KhoJOa121/h0n0GUazjUFChnUo05ThD+fuZXc5/Pk=";
        };
      });
    };
  };
in
with py.pkgs;

buildPythonApplication rec {
  pname = "checkov";
  version = "2.3.202";
  format = "setuptools";

  src = fetchFromGitHub {
    owner = "bridgecrewio";
    repo = pname;
    rev = "refs/tags/${version}";
    hash = "sha256-cJGHby6g4ndz031vxLFmQ9yUAB6lsyGff3eM8vjxUbc=";
  };

  patches = [
    ./flake8-compat-5.x.patch
  ];

  pythonRelaxDeps = [
    "dpath"
    "bc-detect-secrets"
    "bc-python-hcl2"
    "pycep-parser"
    "networkx"
  ];

  nativeBuildInputs = [
    pythonRelaxDepsHook
    setuptools-scm
  ];

  propagatedBuildInputs = [
    aiodns
    aiohttp
    aiomultiprocess
    argcomplete
    bc-detect-secrets
    bc-jsonpath-ng
    bc-python-hcl2
    boto3
    cachetools
    charset-normalizer
    cloudsplaining
    colorama
    configargparse
    cyclonedx-python-lib
    deep_merge
    docker
    dockerfile-parse
    dpath
    flake8
    gitpython
    igraph
    jmespath
    jsonschema
    junit-xml
    networkx
    openai
    packaging
    policyuniverse
    prettytable
    pycep-parser
    pyyaml
    semantic-version
    tabulate
    termcolor
    tqdm
    typing-extensions
    update_checker
  ];

  nativeCheckInputs = [
    aioresponses
    mock
    pytest-asyncio
    pytest-mock
    pytest-xdist
    pytestCheckHook
    responses
  ];

  preCheck = ''
    export HOME=$(mktemp -d);
  '';

  disabledTests = [
    # No API key available
    "api_key"
    # Requires network access
    "TestSarifReport"
    "test_skip_mapping_default"
    # Flake8 test
    "test_file_with_class"
    "test_dataclass_skip"
    "test_typing_class_skip"
    # Tests are comparing console output
    "cli"
    "console"
    # Starting to fail after 2.3.202
    "test_non_multiline_pair"
  ];

  disabledTestPaths = [
    # Tests are pulling from external sources
    # https://github.com/bridgecrewio/checkov/blob/f03a4204d291cf47e3753a02a9b8c8d805bbd1be/.github/workflows/build.yml
    "integration_tests/"
    "tests/ansible/"
    "tests/arm/"
    "tests/bicep/"
    "tests/cloudformation/"
    "tests/common/"
    "tests/dockerfile/"
    "tests/generic_json/"
    "tests/generic_yaml/"
    "tests/github_actions/"
    "tests/github/"
    "tests/kubernetes/"
    "tests/sca_package_2"
    "tests/terraform/"
    # Performance tests have no value for us
    "performance_tests/test_checkov_performance.py"
    # No Helm
    "dogfood_tests/test_checkov_dogfood.py"
  ];

  pythonImportsCheck = [
    "checkov"
  ];

  postInstall = ''
    chmod +x $out/bin/checkov
  '';

  meta = with lib; {
    description = "Static code analysis tool for infrastructure-as-code";
    homepage = "https://github.com/bridgecrewio/checkov";
    changelog = "https://github.com/bridgecrewio/checkov/releases/tag/${version}";
    longDescription = ''
      Prevent cloud misconfigurations during build-time for Terraform, Cloudformation,
      Kubernetes, Serverless framework and other infrastructure-as-code-languages.
    '';
    license = licenses.asl20;
    maintainers = with maintainers; [ anhdle14 fab ];
  };
}
