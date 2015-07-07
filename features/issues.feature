@issues
Feature: Issues
  As a user of the teelogger gem
  When I file an issue 
  I expect a regression test from it

  @issue_7
  Scenario: Complex data causes exception in filter
    Given I create a TeeLogger for regression testing issues
    And I log complex data
    Then I expect there not to be an exception
