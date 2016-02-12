Feature: Running the program
  Scenario: User runs the program without params
    When I run `awsssh`
    Then the exit status should be 0
    And the output should contain "Commands:"

  Scenario: User runs the program with version parameter
    When I run `awsssh version`
    Then the exit status should be 0
    And the output should contain "version"

  Scenario: User runs the program with list_profiles parameter
    Given a file named "bla" with:
    """
    [testprofile]
    aws_access_key_id=ABC
    aws_secret_access_key=XYZ
    region=us-east-1
    """
    When I run `awsssh list_profiles`
    Then the output should contain "testprofile"

  Scenario: User runs the program with list_server parameter
    When I run `awsssh list_server`
    Then the exit status should be 0
    And the output should contain "ERROR"
    And the output should contain "Usage"

  Scenario: User runs the programm without `AWS_CREDENTIAL_FILE`
    Given I set the environment variables to:
      | variable           | value      |
      | AWS_CREDENTIAL_FILE |  |
    When I run `awsssh list_profiles`
    Then the output should contain "$AWS_CREDENTIAL_FILE not set"
    And the exit status should not be 0

  Scenario: User runs the programm woth wrong `AWS_CREDENTIAL_FILE`
    Given I set the environment variables to:
      | variable           | value      |
      | AWS_CREDENTIAL_FILE | ./test.txt |
    When I run `awsssh list_profiles`
    Then the output should contain "Credential File not found."
    And the exit status should not be 0
