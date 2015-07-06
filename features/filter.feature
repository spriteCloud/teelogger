@filter
Feature: Filter
  As a user of the teelogger gem
  When I use the Filter class
  I expect it to work as documented.

  @filter_01
  Scenario Outline: Replace patterns in Strings
    Given I create a TeeLogger for testing filters
    And I write a log message containing the word "<word>"
    Then I expect the log message to <condition> the word "<word>"

    Examples:
      | word           | condition   |
      | hello          | contain     |
      | hello=123      | contain     |
      | --hello=123    | contain     |
      | hello: 123     | contain     |
      | password=123   | not contain |
      | password: 123  | not contain |
      | --password=123 | not contain |

  @filter_02
  Scenario Outline: Replace patterns in Strings in Arrays
    Given I create a TeeLogger for testing filters
    And I write a log message containing the word "<word>" in an Array
    Then I expect the log message to <condition> the word "<word>"

    Examples:
      | word           | condition   |
      | hello          | contain     |
      | hello=123      | contain     |
      | --hello=123    | contain     |
      | hello: 123     | contain     |
      | password=123   | not contain |
      | password: 123  | not contain |
      | --password=123 | not contain |

  @filter_03
  Scenario Outline: Replace patterns in Strings in Hashes
    Given I create a TeeLogger for testing filters
    And I write a log message containing the value "<word>" for the key "<key>" in a Hash
    Then I expect the log message to <condition> the word "<word>"

    Examples:
      | key      | word         | condition   |
      | hello    | MUST REMAIN  | contain     |
      | password | TO BE HIDDEN | not contain |

  @filter_04
  Scenario Outline: Replace patterns in CLI-like arrays
    Given I create a TeeLogger for testing filters
    And I write a log message containing the word sequence "<word1>", "<word2>"
    Then I expect the log message to <condition> the word "<word2>"

    Examples:
      | word1    | word2        | condition   |
      | hello    | MUST REMAIN  | contain     |
      | password | TO BE HIDDEN | not contain |

  @filter_05
  Scenario Outline: Ensure custom filter words work
    Given I create a TeeLogger for testing filters
    And I set filter words to include "<filter>"
    And I write a log message containing the word "<word>"
    Then I expect the log message to <condition> the word "<word>"

    Examples:
      | filter | word    | condition   |
      | foo    | foo=123 | not contain |
      | bar    | foo=123 | contain     |
      | foo    | bar=123 | contain     |
      | bar    | bar=123 | not contain |

  @filter_06
  Scenario: Custom filter
    Given I create a TeeLogger for testing filters
    And I register a custom filter
    And I write a log message containing the word "foo"
    Then I expect the log message to not contain the word "foo"
