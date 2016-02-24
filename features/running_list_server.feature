Feature: Running the program with list_server
  Scenario: User runs the program without profile
    When I run `awsssh list_server`
    Then the exit status should be 0
    And the output should contain "ERROR"
    And the output should contain "Usage"

  Scenario: User runs the program with unknown profile
    Given a file named "credentials" with:
    """
    [testprofile]
    aws_access_key_id=ABC
    aws_secret_access_key=XYZ
    region=us-east-1
    """
    When I run `awsssh list_server unkown`
    Then the output should contain "Profile `unkown` not found. Try `awsssh list_profiles`"
    And the exit status should not be 0
