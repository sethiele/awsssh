Feature: Running the program
  Scenario: User runs the program without params
    When I run `awsssh`
    Then the exit status should be 0
    And the output should contain "Commands:"

  Scenario: User runs the program with version parameter
    When I run `awsssh version`
    Then the exit status should be 0
    And the output should contain "version"
