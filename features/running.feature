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
    When I run `awsssh list_profiles`
    Then the exit status should be 0
    And the output should contain "List of all known AWS Accounts"

  Scenario: User runs the program with list_server parameter
    When I run `awsssh list_server`
    Then the exit status should be 0
    And the output should contain "ERROR"
    And the output should contain "Usage"
