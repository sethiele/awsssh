Feature: Running the program with list_profiles
  Scenario: User runs the program
    Given a file named "credentials" with:
    """
    [testprofile]
    aws_access_key_id=ABC
    aws_secret_access_key=XYZ
    region=us-east-1
    """
    When I run `awsssh list_profiles`
    Then the output should contain "testprofile"

  Scenario: User runs without `AWS_CREDENTIAL_FILE`
    Given I set the environment variables to:
      | variable           | value      |
      | AWS_CREDENTIAL_FILE |  |
    When I run `awsssh list_profiles`
    Then the output should contain "$AWS_CREDENTIAL_FILE not set"
    And the exit status should not be 0

  Scenario: User runs with wrong `AWS_CREDENTIAL_FILE`
    Given I set the environment variables to:
      | variable           | value      |
      | AWS_CREDENTIAL_FILE | ./test.txt |
    When I run `awsssh list_profiles`
    Then the output should contain "Credential File not found."
    And the exit status should not be 0
